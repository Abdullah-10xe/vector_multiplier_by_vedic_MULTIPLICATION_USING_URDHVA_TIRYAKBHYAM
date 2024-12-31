********************************************************************************************************

  Autor name    : Abdullah Jhatial   
  Desigination  : Associate engineer                                                                                                            
  Company       : 10xengineers     https://10xengineers.ai/                                                   
  gmail         : abdullah.jhatial@10x.ai                                               
   
  Designed 32 bit Vector mult based on  Vedic multiplication   
  with precision of 8bit ,16bit and 32bit   
  supported instructions are MUL,MULH, MULHU,MULHSU
  3 staged pipelined 
  operating frequency 2 GHz
    
********************************************************************************************************
--------------------------------------------------------------------------------------------------------
<hr style="border: none; border-top: 5px solid black;"                            />

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
 **Update corners cases by appending more cases in decleared arraies**<br>
///////////////////////////////////////////////////////////////////////////////////////////////////////////<br>
 ## Signal Descriptions

| **Signal**   | **Width** | **Description**                                                                 |
|--------------|-----------|---------------------------------------------------------------------------------|
| `operand_a`  | 32-bit    | Operand_a is a 32-bit vector. Its element sizes interpret based on the precision signal. |
| `operand_b`  | 32-bit    | Operand_b is a 32-bit vector. Its element sizes interpret based on the precision signal. |
| `precision`  | 2-bit     | Precision signal defines the element size in the vector. Supported precisions are:  |
|              |           | - `00`: 4 byte size elements                                                   |
|              |           | - `01`: 2 half-word size elements                                              |
|              |           | - `10`: Word size elements                                                     |
| `opcode`     | 2-bit     | Opcode signal defines the type of operation. Supported operations are:         |
|              |           | - `00`: MUL                                                                    |
|              |           | - `01`: MULH                                                                   |
|              |           | - `10`: MULHU                                                                  |
|              |           | - `11`: MULHSU                                                                 |
| `mul_out`    | 32-bit    | Mul_out is the result of the operation as determined by the precision and opcode signals. |

 //////////////////////////////////////////////////////////////////////////////////////////////////////////

- **For more detail's refer IP Document and slides**

//////////////////////////////////////////////////////////////////////////////////////////////////////////
![full_system-Page-11 drawio (3)](https://github.com/user-attachments/assets/2b032dba-a717-4d85-92fc-8acc71fe688b)
