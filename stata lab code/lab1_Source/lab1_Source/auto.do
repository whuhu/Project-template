	
******************************************************************************
******************************************************************************
**   Lab1  : Introduction to Stata           
**   Task  : do文档介绍
**   Date  : 2020.09.15
******************************************************************************
******************************************************************************	
	
	clear all

*************注释语句***********	
	
	*示例：
    * 第一种注释方式
	sysuse auto
    sum price weight  /*查看price与weight变量部分统计量*/
    gen x = 5         // 生成取值为5的变量x

*************断行***************		
	
    *-断行，三种方式： “///” 、 “/* */” 、 #delimit 命令     
     
	 
	*-第一种断行方式：  ///				
    sysuse auto, clear  //调用数据
    sum price weight length gear turn
    tabstat price weight length gear turn ,            /// 物理断行，逻辑一行
           stats(mean sd p5 p25 med p75 p95 min max)   ///
           format(%6.2f) c(s)    
        
		
	*-第二种断行方式： /* */        			   
    sysuse auto, clear
    sum price weight length gear turn
    tabstat price weight length gear turn ,        /*
    */ stats(mean sd p5 p25 med p75 p95 min max)   /*
    */ format(%6.2f) c(s) 
       
       
	*-第三种断行方式： #delimit 命令    ///表示出现;才结束 	
	sysuse auto, clear
    #delimit ;                           //delimit声明
    tabstat price weight length gear turn ,            
    stats(mean sd p5 p25 med p75 p95 min max) 
          format(%6.2f) c(s) ;
		  #delimit cr