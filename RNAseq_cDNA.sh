#!/bin/bash

####################################CONFIGERATION INFORMATION#########################################################
###LOCATIONS AND SAMPLE NAMES#########################################################################################
echo "Enter the path to the directory where your files are located and press ENTER:" 
read PROJECT_DIR

echo "common name of your sample file and press ENTER:"
read SAMPLE_NAME


echo "Enter the name of your formated reference file and press ENTER:"

read Reference_1

echo "Enter number of samples and press ENTER"

read number

###################################indexing the reference##################################################################

#bwa index Reference_1 #uncomment this if you need to creat the index

###################################SOFTWARE SETTINGS##################################################################
###Q_TRIM AND ADAPTER REMOVING#####
FASTQ_TYPE="sanger"
QUALIY_THRESHOLD=20
MIN_LENGTH=40
ADAPTER_SEQ=AGATCGGAAGAGCACACGTCTGAACTCCAGTCAC
ADAPTER_SEQ_RVC=TCTAGCCTTCTCGTGTGCAGACTTGAGGTCAGTG
U_ADAPTER_SEQ=ACACTCTTTCCCTACACGACGCTCTTCCGATCT
U_ADAPTER_SEQ_RVC=TGTGAGAAAGGGATGTGCTGCGAGAAGGCTAGA
A_adapter=AAAAAAAAAAAAAAAAAAAAAAAAAA
T_adapter=TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT
#######################################################################################################################
for i in {1..$number} 
do {


###################################File downloads#####################################################################

FIRST_SAMPLE_LOC=$PROJECT_DIR/${PROJECT_SAMPLE_DIR}/${SAMPLE_NAME}${i}_R1.fastq
SECCOND_SAMPLE_LOC=$PROJECT_DIR/${PROJECT_SAMPLE_DIR}/${SAMPLE_NAME}${i}_R2.fastq

####################################Fastqc#############################################################################
QTRIM_DATA=${PROJECT_DIR}/${SAMPLE_NAME}${i}/PREPROCESSING
mkdir -p $QTRIM_DATA
mkdir $QTRIM_DATA/FASTQC
mkdir $QTRIM_DATA/FASTQC/Before_Q_Trim
cd $QTRIM_DATA/FASTQC/Before_Q_Trim
fastqc $FIRST_SAMPLE_LOC $SECCOND_SAMPLE_LOC -o $PWD

####################################Adapter Removing####################################################################
ADP_REM=$QTRIM_DATA/Adapter_Removed
mkdir $ADP_REM
cd $ADP_REM

cutadapt --format=fastq --adapter=$ADAPTER_SEQ --adapter=$ADAPTER_SEQ_RVC --adapter=$U_ADAPTER_SEQ --adapter=$U_ADAPTER_SEQ_RVC --adapter=$A_adapter --adapter=$T_adapter --error-rate=0.1 --times=1 --overlap=6 --output=${SAMPLE_NAME}${i}_R1 $FIRST_SAMPLE_LOC > Adapter_removed_1.stdout
cutadapt --format=fastq --adapter=$ADAPTER_SEQ --adapter=$ADAPTER_SEQ_RVC --adapter=$U_ADAPTER_SEQ --adapter=$U_ADAPTER_SEQ_RVC  --adapter=$A_adapter --adapter=$T_adapter --error-rate=0.1 --times=1 --overlap=6 --output=${SAMPLE_NAME}${i}_R2 $SECCOND_SAMPLE_LOC > Adapter_removed_2.stdout
####################################Q-Trim##############################################################################
Q_TRIMMED=$QTRIM_DATA/Q-Trimmed
mkdir $Q_TRIMMED
cd $Q_TRIMMED
trim-fastq.pl --input1 $QTRIM_DATA/Adapter_Removed/${SAMPLE_NAME}${i}_R1 --input2 $QTRIM_DATA/Adapter_Removed/${SAMPLE_NAME}${i}_R2 --output ${SAMPLE_NAME}${i} --quality-threshold $QUALIY_THRESHOLD --fastq-type $FASTQ_TYPE --discard-internal-N --min-length $MIN_LENGTH &>Q_TRIM.stdout
####################################Fastqcaftertrimming#############################################################################
A_Q_T=$QTRIM_DATA/FASTQC/FASTQ_After_Q_Trim
mkdir $A_Q_T
cd $A_Q_T
fastqc $QTRIM_DATA/Q-Trimmed/${SAMPLE_NAME}${i}_1 $QTRIM_DATA/Q-Trimmed/${SAMPLE_NAME}${i}_2 $QTRIM_DATA/Q-Trimmed/${SAMPLE_NAME}${i}_SE -o $PWD

##BWA MAPPING ########################################################################################

MAP=${PROJECT_DIR}/${SAMPLE_NAME}${i}/MAPPING
mkdir $MAP
cd $MAP
bwa aln -n 2 -t 10  $Reference_1 $QTRIM_DATA/Q-Trimmed/${SAMPLE_NAME}${i}_1> R1.sai
bwa aln -n 2 -t 10  $Reference_1 $QTRIM_DATA/Q-Trimmed/${SAMPLE_NAME}${i}_2 > R2.sai
bwa aln -n 2 -t 10  $Reference_1 $QTRIM_DATA/Q-Trimmed/${SAMPLE_NAME}${i}_SE > R3.sai
##########Paired end Reads##################################
bwa sampe  $Reference_1 R1.sai R2.sai $QTRIM_DATA/Q-Trimmed/${SAMPLE_NAME}${i}_1 $QTRIM_DATA/Q-Trimmed/${SAMPLE_NAME}${i}_2 > ${SAMPLE_NAME}${i}_PE_Reads.sam
##########Single end Reads##################################
bwa samse $Reference_1  R3.sai $QTRIM_DATA/Q-Trimmed/${SAMPLE_NAME}${i}_SE > ${SAMPLE_NAME}${i}_SE_Reads.sam
} done


####################################Counting reads#########################################################
sam2count=${PROJECT_DIR}/Count
mkdir $sam2count
cd $sam2count
#######################################################################################################################
for i in {1..$number} 
do {

################################### copying all sam file to current location #####################################################################

FIRST_SAMPLE_LOC=$PROJECT_DIR/${SAMPLE_NAME}$i/MAPPING/${SAMPLE_NAME}${i}_PE_Reads.sam

SECCOND_SAMPLE_LOC=$PROJECT_DIR/${SAMPLE_NAME}$i/MAPPING/${SAMPLE_NAME}${i}_SE_Reads.sam

####################################counting reads in each sam file#############################################################################
cp $FIRST_SAMPLE_LOC $SECCOND_SAMPLE_LOC $PWD
} done

####################################counting#############################################################################
sam2counts.py *.sam
rm *.sam # remove sam files 



