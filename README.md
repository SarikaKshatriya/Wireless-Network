# Wireless-Network
Matlab Project:Viterbi algorithm in matlab 

Objective: Decode convolutionally encoded data using Viterbi algorithm.

Technology Used: MatLab and its functions to encode and decode are used to generate the Trellis and compare the original and decoded sequences.

Description:
Initially  generate Random Data(1000 bits-0 or 1 only) in binary form without using rand function.

Part 1
Encoding: Generate a Trellis Diagram, for randomly generated input data. The trellis will be for four different states with combination of 0 and 1.The Trellis lines with current active path will be considered which would be later used.

Decoding: Decoding involves use of Viterbi Algorithm where compare received sequence with all possible paths. Coded sequence received from Trellis is used to find the most likely path. Use hamming distance for the comparison, as an active path is a valid path through the Trellis whose hamming distance is minimum. At this stage the output of the Decoder is compared with the input of Encoder. 

Part 2
For Part 2 the same input data will be used. But,add error bits in the output of the encoder. To get this error bit,  generate a random variable say x and divide it by 1000. If the initial and decoded sequence does not match, then we  keep changing value of x till it produce the correct result. 

