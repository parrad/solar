 # Copyright (C) 2011, 2010, 2009 Oscar Perpiñán Lamigueiro
 #
 # This program is free software; you can redistribute it and/or
 # modify it under the terms of the GNU General Public License
 # as published by the Free Software Foundation; either version 2
 # of the License, or (at your option) any later version.
 #
 # This program is distributed in the hope that it will be useful,
 # but WITHOUT ANY WARRANTY; without even the implied warranty of
 # MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 # GNU General Public License for more details.
 #
 # You should have received a copy of the GNU General Public License
 # along with this program; if not, write to the Free Software
 # Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
 #/
fCompD<-function(sol, G0d, corr='CPR',f){

  if (class(sol)=='Sol') {
    Bo0d<-coredata(sol@solD$Bo0d)
    indexSol <- indexD(sol)
  } else {# sol es un zoo
    Bo0d <- coredata(sol$Bo0d)
    indexSol <- index(sol)
  }
##index de G0d
    if (class(G0d)=='Meteo') {
    indexG0d=indexD(G0d)
  } else {# G0d es un zoo
    indexG0d=index(G0d)
  }

  ## stopifnot(identical(indexG0d, indexSol)) ##fail sometimes due to tzone attribute
  stopifnot(isTRUE(all.equal(indexG0d, indexSol,  check.attributes = FALSE)))

if (corr!='none'){

  ##Extraigo datos
  if (class(G0d)=='Meteo') {
    G0d=coredata(getG0(G0d))
  } else {
    G0d <-coredata(G0d)
  }

  is.na(G0d) <- (G0d>Bo0d)

  Ktd=G0d/Bo0d
	
  Fd=switch(corr,
    CPR=FdKtCPR(Ktd),     ##Correlacion global-difusa diaria de Collares Pereira y Rabl
    Page=FdKtPage(Ktd),     ##Correlación global difusa para medias mensuales de Page
    LJ=FdKtLJ(Ktd), ##Correlación global difusa para medias mensuales de Liu y Jordan
    EKDd=FdKtEKDd(Ktd, sol), ##Correlación global difusa diaria de Erbs et al
    CLIMEDd=FdKtCLIMEDd(Ktd), ##Correlación global difusa diaria de CLIMED
    user=f(Ktd), ##Correlación propuesta por el usuario
    stop('Wrong descriptor of correlation Fd-Ktd.')
    )

  D0d=Fd*G0d
  B0d=G0d-D0d

} else {##corr=='none', y por tanto G0d es multivariante con G0d, D0d y B0d

  if (class(G0d)=='Meteo') {
    IrrData=getData(G0d)##Ahora G0d es multivariante
  } else {
    IrrData <-G0d
  }

  is.na(IrrData) <- (IrrData$G0d>Bo0d)

  D0d=coredata(IrrData$D0d)
  B0d=coredata(IrrData$B0d)
  G0d=coredata(IrrData$G0d)
  
  Ktd=G0d/Bo0d
  Fd=D0d/G0d
  }
  
  result<- zoo(data.frame(Fd, Ktd, G0d, D0d, B0d), 
               order.by=indexSol)
  result
}
