#! /bin/Rscript
# inherit from consensus2genome.R

if(cover==T){
  
  # print(length(blast$V1))
  # print((cons_len))
  coverage=matrix(rep(0, length(blast$V1)*as.numeric(cons_len)), byrow = T, ncol = as.numeric(cons_len))
  
  for(i in 1:length(blast$V1)){ #FOR EACH RM HIT
    if(blast$V4[i] == blast$V3[i] || blast$V4[i] == blast$V5[i]){
      #print("skip hit")
      } else if(blast$V7[i] == "+" && blast$V4[i] <= cons_len){
      # print(length(coverage[1,]))
      # print(blast[i,])
      # print(length(coverage[i,c(blast$V3[i]:(blast$V4[i]-1))]))
      # print(length(rep(1, abs(blast$V3[i]-blast$V4[i]))))
      coverage[i,c(blast$V3[i]:(blast$V4[i]-1))] <- rep(1, abs(blast$V3[i]-blast$V4[i]))
    } else if(blast$V7[i] == "C" &&  blast$V4[i] <= cons_len){ # IF "C"
       #print(length(coverage[1,]))
       #print(blast[i,])
       #print(length(coverage[i,c(blast$V5[i]:(blast$V4[i]-1))]))
       #print(length(rep(1, abs(blast$V5[i]-blast$V4[i]))))
      coverage[i,c(blast$V5[i]:(blast$V4[i]-1))] <- rep(1, abs(blast$V5[i]-blast$V4[i]))
    }
  }

  
  
  # TO FIX: trace the coverage on the left graph
  #points(colSums(coverage), type='l', axes = F, ylab = NA, xlab = NA, col=covcol, ylim = c(0, max(colSums(coverage))))
  #axis(side = 4)
  #mtext(side = 4, line = 3, 'consensus coverage (bp)')
  
  ## import removator
  removator<-function(covM){
    as.data.frame(covM)->covMT
    covMT$bp=rownames(covMT)
    plot(covM, type = "l")
    abline(h = mean(covM), col = "green")
    abline(h = 0.05*mean(covM), col = "blue")
    
    drops=covMT[covMT$covM <  0.05*mean(covM),]
    
    if(length(drops$bp) == 0){
      
      #return("NOTRIM")
      
    } else {
      
      for(i in 1:length(covMT$covM)){
        abline(v = drops$bp[i], col=rgb(0,0,0,alpha=0.3)) 
      } # for loop of remotivator function
      # print the breakpoints from coverage
      return(unname(tapply(as.numeric(drops$bp), cumsum(c(1, diff(as.numeric(drops$bp))) != 1), range)))
      #print(drops)
    }  #points(covM, type = "l", col = rgb(0,0,0,alpha=0.3) )
    
    # makes the second graph
  }
  
  return(removator(colSums(coverage)))
  
}#IF coverage asked (default)
