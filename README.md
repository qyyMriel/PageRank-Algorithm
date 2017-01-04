# PageRank-Algorithm
This project is an NOC based implementation of PageRank algorithm, the cornerstone of web search engine, in Verilog language.
##Description
This project is an NOC based implementation of PageRank algorithm, the cornerstone of web search engine, in Verilog language. In the other words, it is an on chip implementation instead of point-to point. Our design consists of three parts: CPU, NOC and a sorting module. The CPU is used to initialize, calculate and update the value of scores once the adjacency matrix is given. The NOC is used to transmit updated score between local CPU and distant CPU. The sorting module is used to sort the converged scores in a descending order. In this report, we assume there are 64 websites in the network and the network is divided into four parts with 16 websites each. Only the top 10 websites’ ID and score are required to be displayed.


![alt Image of final Result](https://github.com/NYU-CS6313-Fall16/Reddit-Threads-17/blob/master/png/Hot1.png?raw=true)
