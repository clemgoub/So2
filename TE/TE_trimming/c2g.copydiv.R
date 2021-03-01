#! /bin/Rscript
#inherit from consensus2genome.R
#print(blast)
#list of almost full length fragments
full1=blast[abs(blast$V3-blast$V4) >= FL_thresh*as.numeric(cons_len) & blast$V7 == "+",] ###########REVERSE IF "C"
full2=blast[abs(blast$V5-blast$V4) >= FL_thresh*as.numeric(cons_len) & blast$V7 == "C",]
full=rbind(full1, full2)
#print(head(full))#debug
#print(full)
#print(cons_len)
#graph
#return(blast)
par(mar=c(2.5,2.5,2.5,2.5))

plot(range(0, cons_len), range(0, max(blast$V6)), type = "n", main=paste("TE: ", as.character(blast[1,1]), "\n cons. size: ", as.character(cons_len), "bp; RM hits: ", as.character(length(blast$V1)), " (", as.character(length(full$V1))," >=",as.character(as.numeric(FL_thresh)*100),"% cons. size); +/- ratio: ", round(table(blast$V7 == "+")[1]/table(blast$V7 == "+")[2], 3), sep = ""), cex.main = 0.5, xlab = "TE consensus (bp)", ylab = "divergence to consensus (%)")

for(i in 1:length(blast$V1)){

if(blast$V7[i] == "+"){
    segments(blast$V3[i], blast$V6[i], blast$V4[i], blast$V6[i], col=rgb(0,0,0,alpha=alpha))
    } else if(blast$V7[i] == "C"){
    segments(blast$V5[i], blast$V6[i], blast$V4[i], blast$V6[i], col=rgb(0,0,0,alpha=alpha))
    }
}

if(length(full$V1) != 0){
for(i in 1:length(full$V1)){
    if(full$V7[i] == "+"){
        segments(full$V3[i], full$V6[i], full$V4[i], full$V6[i], col=rgb(0.5,0,0, alpha=full_alpha), lwd=1.5)
        } else if(full$V7[i] == "C"){
        segments(full$V5[i], full$V6[i], full$V4[i], full$V6[i], col=rgb(0,0,0.5,alpha=full_alpha))
        }
} # ROF
} # FI
