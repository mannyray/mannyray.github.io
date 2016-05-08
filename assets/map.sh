#!/bin/bash
SAVEIFS=$IFS
IFS=$(echo -en "\n\b")
counter=1
base=$(pwd)
echo > edges.txt
echo > vertexWeight.txt
function recurse(){
	local currentDirectory=$counter

	for file in `(ls -p | grep -v /) `
	do
		echo " "
		echo " "
		ls -p | grep -v /
		echo " "
		counter=$((counter+1))
		#echo $currentDirectory $counter
		echo  $counter ":" $(wc -c < $file) "/1000", >> $base/vertexWeight.txt
		echo "(" $currentDirectory ,$counter"),">>  $base/edges.txt
	done

	pwd


	for directory in ` find . -maxdepth 1 -mindepth 1 -type f -not -path '*/\.*'`
	do
		echo $directory	
	done

	for directory in ` find . -maxdepth 1 -mindepth 1 -type d -not -path '*/\.*'`
	do

		dir=$(echo $directory |  sed 's/ \+/\\ /g' | tr -d "\r") #
		#echo $dir
		counter=$((counter+1))
		echo "(" $currentDirectory ,$counter")", >>  $base/edges.txt

		eval cd $dir

		recurse
	
	done
	cd ..
}


recurse
IFS=$SAVEIFS
cd $base/
echo > draw.py
echo "import networkx as nx" >> draw.py
echo "import numpy as np">> draw.py
echo "import matplotlib.pyplot as plt">> draw.py
echo "import pygraphviz">> draw.py
echo "from networkx.drawing.nx_agraph import graphviz_layout">> draw.py


echo "G = nx.Graph()">> draw.py
echo "G.add_edges_from(">> draw.py
echo "[">> draw.py

sed '$ s/.$//' edges.txt >> draw.py
echo "])">>draw.py
echo "val_map = {1: 10}">> draw.py
echo "values = [val_map.get(node, 0.25) for node in G.nodes()]" >>draw.py

echo "val_z = {1: 1000,">>draw.py

sed '$ s/.$//' vertexWeight.txt >> draw.py
echo "}">>draw.py
echo "vals = [val_z.get(node, 0.25) for node in G.nodes()]" >> draw.py
echo "pos = graphviz_layout(G, prog=\"twopi\", root=1)" >> draw.py
echo "nx.draw(G, pos,node_color=values,node_size=vals," >> draw.py
echo "with_labels=False," >> draw.py
echo "alpha=0.5," >> draw.py
echo ")" >> draw.py
#nx.draw_networkx_edges(G,pos, cmap = plt.get_cmap('jet'), node_color = values)
echo "plt.show()" >> draw.py

python draw.py

rm edges.txt
rm vertexWeight.txt
rm draw.py


