# The Graph Structure of Software Development

This repository contains the data and a replication package for the article:
*The Graph Structure of Software Development*.

Antoine Pietri$^{1}, Guillaume Rousseau^{2} and Stefano Zacchiroli^{3}
1. Inria, Paris, France. antoine.pietri@inria.fr
2. Université de Paris, Paris, France. guillaume.rousseau@u-paris.fr
3. LTCI, Tlcom Paris, Institut Polytechnique de Paris, Paris, France. stefano.zacchiroli@telecom-paris.fr

TODO: Add citation string

It contains:

- An explanation on how to reproduce the experiments described in the paper (in
  this `README`);
- The raw results obtained from the version 2020-12-15 of the Software Heritage
  graph (in `experiments/`);
- The notebooks used to generate the figures and tables shown in the paper (in
  `notebooks/`).

## Repeating the study

### Step 0: requirements

To repeat the study, the most limiting factor is required RAM. It is advised to
run the study on a machine with at least ~500 GiB of RAM, so that the graph can
be loaded entirely in memory.

The software requirements are:

- Python 3
- Git
- Maven
- OpenJDK JRE >= 11

On Debian:

    sudo apt install wget python3 python3-venv openjdk-11-jdk

### Step 1: retrieve the compressed Software Heritage graph

For the 2020-12-15 version (estimated size: ~320 GiB):

    wget https://annex.softwareheritage.org/public/dataset/graph/2020-12-15/compressed/graph{{,-transposed}.{graph,obl,offset,properties},.node2type.map}

The experiments take the graph "basename" path as a parameter. If you
downloaded these files in `/srv/swhgraph/`, the *basename* is
`/srv/swhgraph/graph`, because all the files in the directory start with the
basename "graph".

### Step 2: install the swh.graph package

This Python package directly bundles the Java archive that can compute the
experiments. It can be installed in a virtualenv by simply doing:

    python3 -m venv venv
    source venv/bin/activate
    venv/bin/pip install swh.graph==0.4.1

The JAR file will be located in `./venv/share/swh-graph/swh-graph-0.4.1.jar`.

**Alternatively**, it can be compiled from source:

    git clone https://forge.softwareheritage.org/source/swh-graph
    cd swh-graph
    git checkout v0.4.1
    mvn -f java/pom.xml compile assembly:single

The resulting JAR file will be located in `./java/target/swh-graph-0.4.1.jar`


### Step 3: run the experiments

**Warning**: Some of these experiments can take entire weeks. Please read the
paper for details on the expected runtime of each experiment.

Setup variables:

    export JAVA_OPTS="-Xmx300G -server -XX:PretenureSizeThreshold=512M -XX:MaxNewSize=4G -XX:+UseLargePages -XX:+UseTransparentHugePages -XX:+UseNUMA -XX:+UseTLAB -XX:+ResizeTLAB"
    export GRAPH_PATH=CHANGEME/basename/path/of/graph
    export GRAPH_JAR=CHANGEME/path/to/swh-graph-0.4.1.jar
    export RESULT_PATH=CHANGEME/path/to/results

Create output directories:

    mkdir -p "$RESULT_PATH{inout,connectedcomponents,clusteringcoeff,shortestpath}"

#### In-degrees and out-degrees

    java "$JAVA_OPTS" -cp "$GRAPH_JAR" org.softwareheritage.graph.experiments.topology.InOutDegree "$GRAPH_PATH" "$RESULT_PATH/inout"

#### Connected components

    mkdir -p "$RESULT_PATH/connectedcomponents/{full,ori+snp,rel+rev,rev,dir+cnt}"
    java "$JAVA_OPTS" -cp "$GRAPH_JAR" org.softwareheritage.graph.experiments.topology.ConnectedComponents --graph "$GRAPH_PATH" --nodetypes 'ori,snp,rel,rev,dir,cnt' --outdir "$RESULT_PATH/connectedcomponents/full"
    java "$JAVA_OPTS" -cp "$GRAPH_JAR" org.softwareheritage.graph.experiments.topology.ConnectedComponents --graph "$GRAPH_PATH" --nodetypes 'ori,snp' --outdir "$RESULT_PATH/connectedcomponents/ori+snp"
    java "$JAVA_OPTS" -cp "$GRAPH_JAR" org.softwareheritage.graph.experiments.topology.ConnectedComponents --graph "$GRAPH_PATH" --nodetypes 'rel,rev' --outdir "$RESULT_PATH/connectedcomponents/rel+rev"
    java "$JAVA_OPTS" -cp "$GRAPH_JAR" org.softwareheritage.graph.experiments.topology.ConnectedComponents --graph "$GRAPH_PATH" --nodetypes 'rev' --outdir "$RESULT_PATH/connectedcomponents/rev"
    java "$JAVA_OPTS" -cp "$GRAPH_JAR" org.softwareheritage.graph.experiments.topology.ConnectedComponents --graph "$GRAPH_PATH" --nodetypes 'dir,cnt' --outdir "$RESULT_PATH/connectedcomponents/dir+cnt"

#### Clustering coefficient

    java "$JAVA_OPTS" -cp "$GRAPH_JAR" org.softwareheritage.graph.experiments.topology.ClusteringCoefficient --graph "$GRAPH_PATH" --outdir "$RESULT_PATH/clusteringcoeff"

#### Shortest path

    mkdir -p "$RESULT_PATH/connectedcomponents/{rev,dir+cnt}"
    java "$JAVA_OPTS" -cp "$GRAPH_JAR" org.softwareheritage.graph.experiments.topology.AveragePaths --graph "$GRAPH_PATH" --nodetypes rev --outdir "$RESULT_PATH/shortestpath/rev"
    java "$JAVA_OPTS" -cp "$GRAPH_JAR" org.softwareheritage.graph.experiments.topology.AveragePaths --graph "$GRAPH_PATH" --nodetypes dir,cnt --outdir "$RESULT_PATH/shortestpath/dir+cnt"
