import networkx as nx
import sys

def read_graph_from_file(filename):
    G = nx.Graph()
    with open(filename, 'r') as f:
        for line in f:
            node1, node2 = line.strip().split('-')
            G.add_edge(node1, node2)
    return G

graph_file = sys.argv[1]
graph = read_graph_from_file(graph_file)

print("Nodes:", graph.nodes())
print("Edges:", graph.edges())

cliques = list(nx.find_cliques(graph))
print("Cliques:", cliques)

size_3_cliques = [c for c in cliques if len(c) >= 3]
print("Size 3 cliques:", size_3_cliques)

largest_clique = max(cliques, key=len)
largest_clique.sort()
print("Largest clique:", ",".join(largest_clique))
