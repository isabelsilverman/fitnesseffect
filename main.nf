$HOSTNAME = ""
params.outdir = 'results'  


if (!params.plasmid){params.plasmid = ""} 
if (!params.wt_sequence){params.wt_sequence = ""} 
if (!params.p0){params.p0 = ""} 
if (!params.rep1){params.rep1 = ""} 
if (!params.rep2){params.rep2 = ""} 

g_1_reads_g_0 = file(params.plasmid, type: 'any') 
g_2_reads_g_0 = file(params.wt_sequence, type: 'any') 
g_6_reads_g_0 = file(params.p0, type: 'any') 
g_7_reads_g_0 = file(params.rep1, type: 'any') 
g_8_reads_g_0 = file(params.rep2, type: 'any') 


process Calculate_Fitness_effect {

publishDir params.outdir, overwrite: true, mode: 'copy',
	saveAs: {filename ->
	if (filename =~ /heatmap.pdf$/) "heatmap/$filename"
}

input:
 file plasmid from g_1_reads_g_0
 file p0 from g_6_reads_g_0
 file rep1 from g_7_reads_g_0
 file rep2 from g_8_reads_g_0
 file wtseq from g_2_reads_g_0

output:
 file "freq.tsv"  into g_0_outputFileTSV_g_9
 file "heatmap.pdf"  into g_0_outputFilePdf

"""
python /export/fitnesseffect/calcFreq.py -i ${plasmid} -i ${p0} -i ${rep1},${rep2} -o freq.tsv -w ${wtseq}


"""
}


process Generate_bar_plots {

publishDir params.outdir, overwrite: true, mode: 'copy',
	saveAs: {filename ->
	if (filename =~ /freq_barplots.pdf$/) "barplots/$filename"
}

input:
 file freq from g_0_outputFileTSV_g_9

output:
 file "freq_barplots.pdf"  into g_9_outputFilePdf

"""
Rscript /export/fitnesseffect/freq_barplots.R ${freq}
"""
}


workflow.onComplete {
println "##Pipeline execution summary##"
println "---------------------------"
println "##Completed at: $workflow.complete"
println "##Duration: ${workflow.duration}"
println "##Success: ${workflow.success ? 'OK' : 'failed' }"
println "##Exit status: ${workflow.exitStatus}"
}
