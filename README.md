 # Assignment 1 - HMM Signal Source
 
 The task of assignment 1 is to code and verify MatLab methods to generate an output sequence of random real numbers *x = (x1 . . . xt . . . xT)* from an Hidden Markov Model (HMM) with scalar Gaussian output distributions.
 
 As is shown in the diagram below, an HMM is basically consisted of two time-invariant objects, a Markov Chain (MC), and an array of Output Probability Distributions with one distribution for each possible value of the discrete Markov-chain state.
 
 #### HMM diagram 
  <p align="center">
    <img src="https://github.com/txzhao/Pattern-Recognition/blob/master/pic/HMM-diagram.png"/>
  </p>
  
  ## Pipeline
  
  At time frame *t*,
  - Generate a state *St* by sampling the current probability distribution *pt*;
  - Sample an output *Xt* from corresponding sub-source related to current state *St*;
  - Update current probability distribution *pt* with the transition probability vector *A(St, :)*;
  - Go back to the first step and repeat the whole process.
  
  ## How to run

Script ```verify.m``` serves as an entry point of the whole task, and ```testCasePara.m``` contains parameters of different test cases. To start your verification, please first change the variable ```test_name``` at the beginning of ```verify.m``` to the right test-case name ('regular HMM'/'same-mean HMM'/'finite-duration HMM'/'vector-output HMM') defined in ```testCasePara.m```, and then run ```verify.m``` to get outputs.
