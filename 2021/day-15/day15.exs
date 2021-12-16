defmodule Nibbler do
  @type packet :: literal_packet() | operation_packet()

  @type literal_packet :: {
          :literal,
          version :: integer(),
          type :: integer(),
          value :: integer()
        }

  @type operation_packet :: {
          :operation,
          version :: integer(),
          type :: integer(),
          length_type :: integer(),
          sub_packets :: [packet()]
        }

  def check_inputs(pairs) do
    pairs
    |> Enum.map(&check_input(&1))
  end

  def check_input({hex, :unknown}) do
    ans =
      hex
      |> convert()
      |> parse_to_packets()
      |> elem(0)
      |> sum_versions()

    {:success, ans}
  end

  def check_input({hex, value}) do
    ans =
      hex
      |> convert()
      |> parse_to_packets()
      |> elem(0)
      |> sum_versions()

    return_type = if ans === value, do: :success, else: :fail
    {return_type, [wanted: value, got: ans]}
  rescue
    e in RuntimeError -> {:error, e}
  end

  @spec parse_to_packets(encoded :: bitstring) :: [packet()]
  def parse_to_packets(encoded, limit \\ nil)

  def parse_to_packets(encoded, limit), do: do_parse_to_packets(encoded, [], limit)

  def do_parse_to_packets(<<version::size(3), type::size(3), rest::bitstring>>, acc, limit)
      when is_nil(limit) or (is_integer(limit) and limit > 0) do
    case create_packet(version, type, rest) do
      {packet, rest} ->
        limit = if is_nil(limit), do: nil, else: limit - 1
        do_parse_to_packets(rest, [packet | acc], limit)

      nil ->
        do_parse_to_packets(<<>>, [acc], nil)
    end
  end

  def do_parse_to_packets(remaining_encoded, acc, _), do: {Enum.reverse(acc), remaining_encoded}

  @spec create_packet(version :: integer(), type :: integer(), encoded :: bitstring()) ::
          {packet(), bitstring()}

  def create_packet(version, type = 4, encoded) do
    {value, acc} = chomp_value(encoded)
    {{:literal, version, type, value}, acc}
  end

  def create_packet(
        version,
        type,
        <<0::size(1), sub_packet_total_length::size(15), rest::bitstring>>
      ) do
    <<encoded_sub_packets::bitstring-size(sub_packet_total_length), rest::bitstring>> = rest

    {packets, _rest} = parse_to_packets(encoded_sub_packets)

    {{:operation, version, type, 0, packets}, rest}
  end

  def create_packet(
        version,
        type,
        <<1::size(1), number_of_sub_packets::size(11), rest::bitstring>>
      ) do
    {packets, rest} = parse_to_packets(rest, number_of_sub_packets)

    {{:operation, version, type, 1, packets}, rest}
  end

  def create_packet(0, 0, <<>>), do: nil
  def create_packet(0, 0, <<_::size(1)>>), do: nil

  @spec chomp_value(bitstring(), bitstring()) :: {integer(), bitstring()}
  def chomp_value(encoded, acc \\ <<>>)

  def chomp_value(all = <<1::size(1), value_part::size(4), rest::bitstring>>, acc) do
    chomp_value(rest, <<acc::bitstring, value_part::size(4)>>)
  end

  def chomp_value(<<0::size(1), value_part::size(4), rest::bitstring>>, acc) do
    value_bits = <<acc::bitstring, value_part::size(4)>>
    padding = rem(:erlang.bit_size(value_bits), 32)
    value = :binary.decode_unsigned(<<0::size(padding), value_bits::bitstring>>)

    {value, rest}
  end

  def sum_versions(packets, acc \\ 0)

  def sum_versions([packet | rest], acc) do
    case packet do
      {:literal, version, _, _} ->
        sum_versions(rest, acc + version)

      {:operation, version, _, _, sub_packets} ->
        sum_versions(rest, acc + version + sum_versions(sub_packets))

      l when is_list(l) ->
        sum_versions(l, acc)
    end
  end

  def sum_versions([], acc), do: acc

  def convert(hex), do: do_convert(hex, <<>>)

  def do_convert(<<>>, acc), do: acc

  def do_convert(<<head::binary-size(1), rest::binary>>, acc) do
    converted = hex_to_bitstring(head)
    do_convert(rest, <<acc::bitstring, converted::bitstring>>)
  end

  def hex_to_bitstring("0"), do: <<0x0::size(4)>>
  def hex_to_bitstring("1"), do: <<0x1::size(4)>>
  def hex_to_bitstring("2"), do: <<0x2::size(4)>>
  def hex_to_bitstring("3"), do: <<0x3::size(4)>>
  def hex_to_bitstring("4"), do: <<0x4::size(4)>>
  def hex_to_bitstring("5"), do: <<0x5::size(4)>>
  def hex_to_bitstring("6"), do: <<0x6::size(4)>>
  def hex_to_bitstring("7"), do: <<0x7::size(4)>>
  def hex_to_bitstring("8"), do: <<0x8::size(4)>>
  def hex_to_bitstring("9"), do: <<0x9::size(4)>>
  def hex_to_bitstring("A"), do: <<0xA::size(4)>>
  def hex_to_bitstring("B"), do: <<0xB::size(4)>>
  def hex_to_bitstring("C"), do: <<0xC::size(4)>>
  def hex_to_bitstring("D"), do: <<0xD::size(4)>>
  def hex_to_bitstring("E"), do: <<0xE::size(4)>>
  def hex_to_bitstring("F"), do: <<0xF::size(4)>>
end

inputs = [
  {"D2FE28", 6},
  {"8A004A801A8002F478", 16},
  {"620080001611562C8802118E34", 12},
  {"C0015000016115A2E0802F182340", 23},
  {"A0016C880162017C3686B18A3D4780", 31},
  {"420D598021E0084A07C98EC91DCAE0B880287912A925799429825980593D7DCD400820329480BF21003CC0086028910097520230C80813401D8CC00F601881805705003CC00E200E98400F50031801D160048E5AFEFD5E5C02B93F2F4C11CADBBB799CB294C5FDB8E12C40139B7C98AFA8B2600DCBAF4D3A4C27CB54EA6F5390B1004B93E2F40097CA2ECF70C1001F296EF9A647F5BFC48C012C0090E675DF644A675DF645A7E6FE600BE004872B1B4AAB5273ED601D2CD240145F802F2CFD31EFBD4D64DD802738333992F9FFE69CAF088C010E0040A5CC65CD25774830A80372F9D78FA4F56CB6CDDC148034E9B8D2F189FD002AF3918AECD23100953600900021D1863142400043214C668CB31F073005A6E467600BCB1F4B1D2805930092F99C69C6292409CE6C4A4F530F100365E8CC600ACCDB75F8A50025F2361C9D248EF25B662014870035600042A1DC77890200D41086B0FE4E918D82CC015C00DCC0010F8FF112358002150DE194529E9F7B9EE064C015B005C401B8470F60C080371460CC469BA7091802F39BE6252858720AC2098B596D40208A53CBF3594092FF7B41B3004A5DB25C864A37EF82C401C9BCFE94B7EBE2D961892E0C1006A32C4160094CDF53E1E4CDF53E1D8005FD3B8B7642D3B4EB9C4D819194C0159F1ED00526B38ACF6D73915F3005EC0179C359E129EFDEFEEF1950005988E001C9C799ABCE39588BB2DA86EB9ACA22840191C8DFBE1DC005EE55167EFF89510010B322925A7F85A40194680252885238D7374C457A6830C012965AE00D4C40188B306E3580021319239C2298C4ED288A1802B1AF001A298FD53E63F54B7004A68B25A94BEBAAA00276980330CE0942620042E3944289A600DC388351BDC00C9DCDCFC8050E00043E2AC788EE200EC2088919C0010A82F0922710040F289B28E524632AE0",
   991}
]

inputs
|> Nibbler.check_inputs()
|> IO.inspect(label: "finish")
