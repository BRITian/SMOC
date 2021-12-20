# SMOC
Smart Model for Open chromatin region in Rice

Introduction
====
Chromatin accessibility is one of the most important chromatin structural features that determine the degree of nuclear macromolecules accessing chromosomal DNA, which is crucial to gene transcription regulation.Here, we designed and developed a rice-specific SMOC tool based on deep learning algorithms that have multiple layers of CNN architecture for OCR prediction in two rice cultivars NIP and 93-11 in normal and heat stress conditions.

System requirement
=====
1. Python 2.7 or Python 3.5
2. tensorflow 2.0.0
3. keras 2.3.1
4. theano 1.0.4

Quick Start to install the required program
====
1. Install the python 2.7 or 3.5 from Anaconda https://www.anaconda.com/
2. pip install tensorflow==2.0.0 (python=2.7) or pip install tensorflow==2.0.0-alpha0 (python=3.5)
3. pip install keras==2.3.1
4. pip install theano==1.0.4
5. git clone https://github.com/BRITian/smep

Training models
====
The program smep_train_py2.7.py or smep_train_py3.5.py was used to train the prediction model, in the python environment 2.7 or 3.5, respectively. There are four parameters that should be provided with the following order, training filename, test filename, model name,sequence length and class number of the model. In the coding file, the first coloum is the label of the sequence, which is the modified or unmodified state. The followings in the line is the coding data, and each nucleotide is encoded as a number, which the A is encoded as the 0, T is encoded as 1, C is encoded as 2 and G is encoed as 3. Different epigenetic modifications use different training parameters.
The followings are the examples to construct the predicting models in the python environment 2.7.  

1.	The OCRs predicting model  
python smep_train_models_py2.7.py example_Train_file_NIPCK example_Test_file_NIPCK model.h5 147 2  
python smep_train_models_py2.7.py example_Train_file_NIPHS example_Test_file_NIPHS model.h5 147 2  
python smep_train_models_py2.7.py example_Train_file_9311CK example_Test_file_9311CK model.h5 147 2  
python smep_train_models_py2.7.py example_Train_file_9311HS example_Test_file_9311HS model.h5 147 2  

The model file will be constructed in the current directory.  

Prediction the modifications in the sequence
====
The main program smep_prediction.pl could be used to predict the modification in the sequence. There are three parameters (-I -T -O) that should be provided.  

perl smep_prediction.pl -I input_fasta_sequence -T modification_type -O output_file  

-I, The input sequence with fasta format  
-T, The epigenetic modification type. There are six pre-constructed models (5mC, 6mA, m6A, H3K27me3, H3K4me3 or H3K9ac)     
-O, The output file  

The followings are some command examples.  

perl smep_prediction_p2.7.pl -I test_squence.fasta -O test_results.out -T NIPCK
  
The predicted results were saved in the output file. In the predicted file, the first column is the fragment number. The second and third column are the sequence ID and the location of the first nucleic acid in the fragment. The fourth and fifth columns are the predicted flag for the modification marker and the probability. The sixth column is the sequence of the fragment. The flag and its corresponding modification were shown as the followings. For the OCRs, the number 0 and 1 represented the non-modification and modification, respectively.   

