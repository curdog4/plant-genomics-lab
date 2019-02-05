#!/bin/bash

##
# These are our ultimate outputs
REFLIB_CDS=sequences_cds.fasta
REFLIB_PROT=sequences_prot.fasta

##
# This is mostly used as an identifier in the file name
GENE=ppc1

##
# Input file
# In this case, we've combined the CDS for the Ppc1 from Athaliana, Mcrystallinum, and Osativa
#QFILE=Mcrystalinum_${GENE}_cds.fasta
QFILE=query.fasta
for P in ../../phytozome-data/*/*.protein_primaryTranscriptOnly.fa.phr; do
    ##
    # The .phr file ensures that a blast DB has been created
    # the protein_primaryTranscriptOnly.fa is FASTA formatted CDS -> protein translations
    # the CDS data came from Phytozome (for most) or from NCBI

    ##
    # prune the makeblastdb output file suffixes to get to the DB name
    DB=${P%%.phr};
    ##
    # extract the 'species' part of the file name
    SP=$(basename $(dirname $P));
    ##
    # the blastx output table name
    TFILE=searchtables/${SP}_${GENE}_cds-primary_blastx.table
    ##
    # the blast_filter.py output table name
    FFILE=${TFILE/blastx/filtered}
    ##
    # the elbow_filter.py output table name
    EFILE=${TFILE/blastx/elbow}

    ##
    # get blastx output
    echo blastx -query ${QFILE} -db ${DB} -outfmt 6 -evalue 1e-50 -out ${TFILE};
    blastx -query ${QFILE} -db ${DB} -outfmt 6 -evalue 1e-50 -out ${TFILE};

    ##
    # ensure we have some output ('-s': file exists and size is > 0
    if [ -s $TFILE ]; then
        ##
        # run through blast_filter.py, parameters are pretty self-explanatory
        cat $TFILE | $HOME/pgl/bin/python3/bin/python3 $HOME/upgraded-robot/blast_filter.py --query-file $QFILE --query-cds $QFILE --subject-cds ${DB/protein/cds} --subject-prot $DB --coverage 60 --identity 30 | tee $FFILE
    fi

    ##
    # ensure we have output to work with
    if [ -s $FFILE ]; then
        CNT=( $(wc -l $FFILE) )
        ##
        # need > 3 matches for elbow_filter.py
        if [ ${CNT[0]} -gt 3 ]; then
            cat $FFILE | $HOME/pgl/bin/python3/bin/python3 $HOME/upgraded-robot/elbow_filter.py > $EFILE
        else
            cp $FFILE $EFILE
        fi
    fi

    ##
    # ensure we have output to work with
    if [ -s $EFILE ]; then
        ##
        # ensure unique set of sequence IDs
        for SEQID in $(awk '{print $2}' $FFILE | sort -u); do
            ##
            # file name of CDS FASTA data, swap 'cds' for 'protein' in file name
            CDS=${DB/protein/cds}
            if [ ! -e $CDS ]; then
                echo "ERROR: CDS sequence database $CDS not found" >&2
                continue
            fi
            ##
            # ensure no duplicate sequence IDs
            grep -qw $SEQID $REFLIB_CDS
            if [ "$?" == "1" ]; then
                $HOME/pgl/bin/python3/bin/python3 $HOME/upgraded-robot/findseq.py $SEQID $CDS >> $REFLIB_CDS
            fi
            grep -q $SEQID $REFLIB_PROT
            if [ "$?" == "1" ]; then
                $HOME/pgl/bin/python3/bin/python3 $HOME/upgraded-robot/findseq.py $SEQID $DB >> $REFLIB_PROT
            fi
        done
    fi
done
