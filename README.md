*******************************************************************************

  Autor name    : Abdullah Jhatial   
  Desigination  : Associate engineer                                                                                                            
  Company       : 10xengineers     https://10xengineers.ai/                                                   
  gmail         : abdullah.jhatial@10x.ai                                               
   
  Designed 32 bit Vector mult based on  Vedic multiplication   
  with precision of 8bit ,16bit and 32bit   
  supported instructions are MUL,MULH, MULHU,MULHSU
  3 staged pipelined 
  operating frequency 2 GHz
    
**************************************************************************************
////////////////////////////////////////////////////////////////////////////////////////////////////////
- **Sythesis flow**
   - step0 : cd path/syntheis/tcl_script
   - step1:  command : csh
   - step2 :  source cshrc    // tool paths
   - step3 :  tool_invoke -f  tcl_run.tcl
   **for reports check the report folder**

//////////////////////////////////////////////////////////////////////////////////////////////////////////                                                  
- **Sim Flow**
 - step0 : cd path/verif/tcl_xrun
 - step1 : command : csh
 - step2 : source cshrc
 - step3 : xrun -f tcl_xrun.arg
                                                                                                                                                                                                     
 **Number of pass and fail  tests  will be displayed with respect to opcode**
 **if any test fail at any value it will displayed the operands and dut values and expected value**
 **For corner cases make c parameter value 1**
 **Update corners cases by appending more cases in decleared arraies**
 
 //////////////////////////////////////////////////////////////////////////////////////////////////////////

- **For more detail's refer IP Document and slides**

//////////////////////////////////////////////////////////////////////////////////////////////////////////
![full_system-Page-11 drawio (3)](https://github.com/user-attachments/assets/2b032dba-a717-4d85-92fc-8acc71fe688b)
