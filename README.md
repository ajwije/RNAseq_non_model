###Code for RNAseq data analysis

This is a shell script (http://www.freeos.com/guides/lsst/) to combine a few programs. It will take a Illumina paired-end short reads and align them to cDNA collection and extract the number of counts aligned to each cDNA. 

1.  First it will check the quality of the Illumina short read sequences using FastQC 

2.	Preprocess Illumina short reads to remove adapter sequences and trim low quality bases and sequences and to remove poly A and poly T sequences. For this, it will use  cutadapt (http://cutadapt.readthedocs.org/en/latest/guide.html) and trim-fastq.pl  (https://code.google.com/p/popoolation/source/browse/trunk/basic-pipeline/trim-fastq.pl?spec=svn101&r=101).

3.	It will map preprocessed short reads to a set of reference cDNA using BWA (http://bio-bwa.sourceforge.net). 

4.	It will extract the read counts for cDNA using sam2count (https://github.com/vsbuffalo/sam2counts) 


###Requirements:
1.	You need to have above programs installed on your computer and they should be added your path variable.

2.	You can make the script executable by using chmod +x  RNAseq_cDNA.sh

3.	To run the script do ./RNAseq_cDNA.sh 

4.	It will prompt you to enter the following:

  a.	"Enter the path to the directory where your files are located and press ENTER:"  Enter the full path to the directory where your samples are located.
  
  b.	"common name of your sample file and press ENTER:"  If you have 2 samples, they should be named as  (for e.g.,) sample_1, sample _2 . The common name in this case is “sample_” (No quotations). 
  
  c.	"Enter number of samples and press ENTER". In above example 2. 

5.	The script will produce intermediate files in separate folders and each named with sample name. 

###TO DO:
Include a sample data set. 
