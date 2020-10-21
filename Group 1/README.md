# Group 1

The purpose of this project is the control of a DC Motor using **Fuzzy Controller**.

<img src="C:\Users\Dimitris\AppData\Roaming\Typora\typora-user-images\image-20201021015050795.png" alt="image-20201021015050795" style="zoom:80%;" />

The control signal has to meet the following standards:

- **Disturbance Rejection**: For cyclic frequency ω < 1 rad/sec, the gain of the disturbance must not exceed 20 dB.

- Step response must not exceed 5% elevation

- Zero Position Error

- Rise Time less than 160 msec

- V~a~(t) < 200V for t >0

  

To implement the controller I have chosen a PI fuzzy controller. Sampling time was set to 0.01 sec. Verbal variables and their membership functions are shown bellow: 

<img src="C:\Users\Dimitris\AppData\Roaming\Typora\typora-user-images\image-20201021134357446.png" alt="image-20201021134357446" style="zoom:80%;" />

​                                                                                             

Reference signal cannot exceed 150, because ω~max~ = 150 rad/sec. Moreover the range of Δe(k) is [-50,50].

The features of the Fuzzy Controller are:

- Fuzzifier **Singleton**
- Operator AND through min
- Implication Function using **Mamdani** rule
- Operator ALSO through max
- Defuzzifier Center of Sums, **COS**



## Fuzzy Rules Base

Fuzzy Logic Designer, offered by MATLAB, is used to implement the Rules Base.

<img src="C:\Users\Dimitris\AppData\Roaming\Typora\typora-user-images\image-20201021140701152.png" alt="image-20201021140701152" style="zoom:80%;" />



Membership Functions have the following forms:

<img src="C:\Users\Dimitris\AppData\Roaming\Typora\typora-user-images\image-20201021140748336.png" alt="image-20201021140748336" style="zoom:80%;" />





## *Scenario 1*

We investigate the hypothesis of T~L~ = 0.                              
$$
\frac{Ω(s)}{V~a~(s)} = \frac{18.69}{s+12.064}
$$
In automatic control systems a PI controller has the form: 
$$
H_c (s)=K_P+K_I/s = \frac{K_P (s+K_I/K_P )}{s}
$$

Under those cases, the transfer function of the open loop system is:
$$
A(s)=  \frac{18.69 K_P (s+K_I/K_P ) )}{s (s+12.064)}
$$


The system that was described was solved in order to calculate the values of the unknown variables. I have found that the values **K~p~ = 2** and **K~I~ = 51.077** satisfy our requirements.

At this point we can calculate the values of the parameters:

- $$
  a=T_i=K_P/K_I =0.039
  $$

  

- $$
  K= \frac{K_P}{F*a*K_e}=\frac{2}{0.039 F{1}}=51.07
  $$





### Simulink

![image-20201021143008344](C:\Users\Dimitris\AppData\Roaming\Typora\typora-user-images\image-20201021143008344.png)



The reference signal was fed using the tool **signal Builder** and the following function:

![image-20201021143136576](C:\Users\Dimitris\AppData\Roaming\Typora\typora-user-images\image-20201021143136576.png)



With the help of tool **Data Inspector** we can see that our system meets the requirements:

<img src="C:\Users\Dimitris\AppData\Roaming\Typora\typora-user-images\image-20201021143358867.png" alt="image-20201021143358867" style="zoom:80%;" />







To reduce rise time and steady state error the gains went through the process of **comparative tuning**. The value of **K** and **K~e~** was reduced, while the value of **a** was increased.



![image-20201021143839725](C:\Users\Dimitris\AppData\Roaming\Typora\typora-user-images\image-20201021143839725.png)



Observing the Data Inspector is clear that rise time and elevation were significantly reduced.



![image-20201021143940748](C:\Users\Dimitris\AppData\Roaming\Typora\typora-user-images\image-20201021143940748.png)





### Rule Viewer

At this point we will examine the output of the system, when input is fed with the rule **IF e is PS AND Δe is NM\. **

![image-20201021144200867](C:\Users\Dimitris\AppData\Roaming\Typora\typora-user-images\image-20201021144200867.png)





### Surface of output in respect to input

Function **gensurf** was used to produce a graphical relationship between input and output. As output for each fuzzy set is considered its middle point, because of the COS defuzzifier.

<img src="C:\Users\Dimitris\AppData\Roaming\Typora\typora-user-images\image-20201021144630298.png" alt="image-20201021144630298" style="zoom:80%;" />





## *Scenario 2*

The signal stands for the speed of a train. For this reason it is essential to ensure the zero elevation of the output signal. The tuning of the gains leads to the following circuit.



### Simulink

![image-20201021145322685](C:\Users\Dimitris\AppData\Roaming\Typora\typora-user-images\image-20201021145322685.png)



With the help of tool **Data Inspector** we can see that our system meets the requirements:



![image-20201021145336129](C:\Users\Dimitris\AppData\Roaming\Typora\typora-user-images\image-20201021145336129.png)





## *Scenario* 3

The hypothesis of this scenario is that we have a non zero T~L~ that stands for a disturbance.

![image-20201021145605087](C:\Users\Dimitris\AppData\Roaming\Typora\typora-user-images\image-20201021145605087.png)

Our controller has to observe this disturbance and reject it. The goal of this scenario is to compare the functionality of a **Fuzzy PI Controller** and a **Conventional PI Controller**.



### Simulink

The two different controllers were embodied to the initial circuit, in order to compare their responses.

<img src="C:\Users\Dimitris\AppData\Roaming\Typora\typora-user-images\image-20201021145902493.png" alt="image-20201021145902493" style="zoom:150%;" />

![image-20201021145919646](C:\Users\Dimitris\AppData\Roaming\Typora\typora-user-images\image-20201021145919646.png)



With the help of tool **Data Inspector** we can see the responses:



![image-20201021150145948](C:\Users\Dimitris\AppData\Roaming\Typora\typora-user-images\image-20201021150145948.png)







## Conclusion

It is obvious that the **Fuzzy PI Controller** behaves more efficient than the  **Conventional PI Controller**. Not only the rise time is significantly smaller, but also it succeeds a better disturbance rejection. As we can see the gain of the disturbance is: 
$$
20 log⁡(164/150)=0.77<20dB
$$
