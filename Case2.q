#!/bin/bash
#SBATCH --output=Case2.out
#SBATCH --error=Case2.err
##SBATCH --ntasks=1
#SBATCH --mem=20G
##SBATCH --cpus-per-task=16

/opt/apps/matlabR2016a/bin/matlab -nodisplay -singleCompThread -r "Case2 ;quit" 