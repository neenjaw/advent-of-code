require 'set'
require 'io/console'

FLIP_FLOP = '%'.freeze
CONJUNCTION = '&'.freeze
BROADCASTER = 'broadcaster'.freeze
BUTTON = 'button'.freeze
LOW = '-'.freeze
HIGH = '+'.freeze

# Flip-Flop -- Low pulse, flips the flip-flop module on/off
#    - if off, and it receives a low pulse, will turn on and send high pulse
#    - if on, and it receives a low pulse, will turn off and send a low pulse
# Conjunction -- Remember last pulse, default low
#    - if it receives a pulse (one or more) and all are high, it will pulse low
#    - if it receives a pulse (one or more) and any are low, it will pulse high
# Broadcaster -- Broadcasts a pulse to all connected modules, sends same input pulse to all outputs

# start button sends low to broadcaster

# broadcaster -> a, b, c       <type><name> -> <output>[, <output>]*
# %a -> b
# %b -> c
# %c -> inv
# &inv -> a

def read
  node_map = {}
  node_state = {}
  ARGF.read.chomp.split("\n").each do |line|
    type, name, rest = /(%|&)?([a-z]+) -> ([a-z, ]+)/.match(line).captures
    outputs = rest.split(', ')

    state = { type: type || BROADCASTER, name: name, outputs: outputs, inputs: [] }
    node_map[name] = (state).merge(node_map[name] || {})

    outputs.each do |output|
      node_state[output] ||= { inputs: {} }
      node_state[output][:inputs][name] = LOW

      node_map[output] ||= { inputs: [] }
      node_map[output][:inputs] << name
    end

    node_state[name] ||= { inputs: {} }
    if type == FLIP_FLOP
      node_state[name][:state] = :off
    elsif type == CONJUNCTION
      node_state[name] ||= { inputs: {} }
    end
  end

  [node_map, node_state]
end

def run(start: BROADCASTER, node_map:, node_state_input:, tally:)
  node_state = node_state_input
  queue = [[start, LOW, BUTTON]]
  tally[LOW] += 1
  while !queue.empty?
    node, pulse, sender = queue.shift

    if !node_map.key?(node)
      next
    elsif node_map[node][:type] == FLIP_FLOP
      if pulse == LOW && node_state[node][:state] == :off
        node_state[node][:state] = :on
        node_map[node][:outputs].each do |output|
          queue << [output, HIGH, node]
          tally[HIGH] += 1
        end

        # Hacky way to signal that we've seen a determinant
        if ["bt", "dl", "fr", "rv"].include?(node)
          if tally[node].nil?
            tally[node] = HIGH
          end
        end
      elsif pulse == LOW && node_state[node][:state] == :on
        node_state[node][:state] = :off
        node_map[node][:outputs].each do |output|
          queue << [output, LOW, node]
          tally[LOW] += 1
        end
      end
    elsif node_map[node][:type] == CONJUNCTION
      node_state[node][:inputs][sender] = pulse

      if node_state[node][:inputs].values.all? { |v| v == HIGH }
        node_map[node][:outputs].each do |output|
          queue << [output, LOW, node]
          tally[LOW] += 1
        end
      else
        node_map[node][:outputs].each do |output|
          queue << [output, HIGH, node]
          tally[HIGH] += 1
        end

        # Hacky way to signal that we've seen a determinant
        if ["bt", "dl", "fr", "rv"].include?(node)
          if tally[node].nil?
            tally[node] = HIGH
          end
        end
      end
    elsif node_map[node][:type] == BROADCASTER
      node_map[node][:outputs].each do |output|
        queue << [output, pulse, node]
        tally[pulse] += 1
      end
    end
  end

  { node_state: node_state, tally: tally, node_map: node_map }
end

node_map, starting_node_state = read


puts "Part 1"

tally = { LOW => 0, HIGH => 0 }
node_state = Marshal.load(Marshal.dump(starting_node_state))
1000.times do
  output = run(start: BROADCASTER, node_map: node_map, node_state_input: node_state, tally: tally)
  tally = output[:tally]
  node_map = output[:node_map]
  node_state = output[:node_state]
end

pp tally.values.inject(:*)

puts "Part 2"
# :facepalm: The input is graphviz, so I can just use that to figure out the determinants
# https://dreampuf.github.io/GraphvizOnline/#digraph%20G%20%7B%0Aqm%20-%3E%20mj%2C%20xn%0Amj%20-%3E%20hz%2C%20bt%2C%20lr%2C%20sq%2C%20qh%2C%20vq%0Aqc%20-%3E%20qs%2C%20vg%0Ang%20-%3E%20vr%0Aqh%20-%3E%20sq%0Abt%20-%3E%20rs%0Ahh%20-%3E%20qs%2C%20bx%0Agk%20-%3E%20cs%2C%20bb%0Ajs%20-%3E%20mj%0Apc%20-%3E%20mj%2C%20mr%0Amb%20-%3E%20rd%2C%20xs%0Atp%20-%3E%20qs%2C%20ks%0Axq%20-%3E%20tp%2C%20qs%0Abx%20-%3E%20sz%0Amn%20-%3E%20cs%2C%20md%0Acv%20-%3E%20rd%0Arh%20-%3E%20rd%2C%20sv%0Amd%20-%3E%20cs%0Apz%20-%3E%20mj%2C%20vq%0Abz%20-%3E%20rd%2C%20hk%0Ajz%20-%3E%20vk%0Asz%20-%3E%20jz%0Alr%20-%3E%20pz%2C%20mj%0Axs%20-%3E%20cv%2C%20rd%0Akl%20-%3E%20rd%2C%20mb%0Ahz%20-%3E%20pc%0Ahk%20-%3E%20rz%2C%20rd%0Avk%20-%3E%20qc%0Abh%20-%3E%20zm%0Avq%20-%3E%20qm%0Aks%20-%3E%20qs%2C%20nd%0Aqs%20-%3E%20dl%2C%20jz%2C%20bx%2C%20vk%2C%20vg%2C%20hh%2C%20sz%0Adl%20-%3E%20rs%0Alf%20-%3E%20rh%2C%20rd%0Afr%20-%3E%20rs%0Axn%20-%3E%20mj%2C%20qh%0Ahf%20-%3E%20qs%2C%20xq%0Asv%20-%3E%20rd%2C%20ng%0Ars%20-%3E%20rx%0Ard%20-%3E%20ng%2C%20fr%2C%20rz%2C%20lf%2C%20vr%0Acj%20-%3E%20ss%2C%20cs%0Abroadcaster%20-%3E%20hh%2C%20lr%2C%20bp%2C%20lf%0Azs%20-%3E%20cs%2C%20mn%0Avr%20-%3E%20bz%0And%20-%3E%20qs%0Ajb%20-%3E%20cj%2C%20cs%0Arv%20-%3E%20rs%0Abp%20-%3E%20cs%2C%20lx%0Ass%20-%3E%20zs%0Alx%20-%3E%20gk%0Acs%20-%3E%20lx%2C%20ss%2C%20rv%2C%20bh%2C%20bp%0Abb%20-%3E%20bh%2C%20cs%0Amf%20-%3E%20mj%2C%20hz%0Azm%20-%3E%20cs%2C%20jb%0Amr%20-%3E%20mj%2C%20js%0Arz%20-%3E%20kl%0Avg%20-%3E%20hf%0Asq%20-%3E%20mf%0A%0A%7D

determinants = ["bt", "dl", "fr", "rv"]
determinant_appearances = []
tally = { LOW => 0, HIGH => 0 }
node_state = Marshal.load(Marshal.dump(starting_node_state))
i = 1
while true
  output = run(start: BROADCASTER, node_map: node_map, node_state_input: node_state, tally: tally)
  tally = output[:tally]
  node_map = output[:node_map]
  node_state = output[:node_state]

  ["bt", "dl", "fr", "rv"].each do |node|
    if tally[node] && tally[node] == HIGH
      puts "#{node} #{tally[node]} at #{i}"
      tally[node] = false
      determinant_appearances << i
    end
  end

  if ["bt", "dl", "fr", "rv"].all? { |node| tally[node] == false }
    break
  end

  i += 1
end

pp determinant_appearances.reduce(:lcm)
