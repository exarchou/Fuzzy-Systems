# Group 1

The purpose of this project is the control of a DC Motor using a **Fuzzy Controller**.

<p align="center">
<img src="images/1.jpg">
</p>


The control signal has to meet the following standards:

- **Disturbance Rejection**: For cyclic frequency ω < 1 rad/sec, the gain of the disturbance must not exceed 20 dB.

- Step response must not exceed 5% elevation

- Zero Position Error

- Rise Time less than 160 msec

- Va(t) < 200V for t >0

  

To implement the controller I have chosen a PI fuzzy controller. Sampling time was set to 0.01 sec. Verbal variables and their membership functions are shown bellow: 

<p align="center">
<img src="images/2.jpg">
</p>

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

<p align="center">
<img src="images/3.jpg">
</p>



Membership Functions have the following forms:

<p align="center">
<img src="images/4.jpg">
</p>





## *Scenario 1*

We investigate the hypothesis of T<sub>L</sub> = 0.                              

<a href="https://www.codecogs.com/eqnedit.php?latex=\frac{W(s)}{Va(s)}&space;=&space;\frac{18.69}{s&plus;12.064}" target="_blank"><img src="https://latex.codecogs.com/gif.latex?\frac{W(s)}{Va(s)}&space;=&space;\frac{18.69}{s&plus;12.064}" title="\frac{W(s)}{Va(s)} = \frac{18.69}{s+12.064}" /></a>


In automatic control systems a PI controller has the form: 

<a href="https://www.codecogs.com/eqnedit.php?latex=H_c&space;(s)=K_P&plus;K_I/s&space;=&space;\frac{K_P&space;(s&plus;K_I/K_P&space;)}{s}" target="_blank"><img src="https://latex.codecogs.com/gif.latex?H_c&space;(s)=K_P&plus;K_I/s&space;=&space;\frac{K_P&space;(s&plus;K_I/K_P&space;)}{s}" title="H_c (s)=K_P+K_I/s = \frac{K_P (s+K_I/K_P )}{s}" /></a>

Under those cases, the transfer function of the open loop system is:

<a href="https://www.codecogs.com/eqnedit.php?latex=A(s)=&space;\frac{18.69&space;K_P&space;(s&plus;K_I/K_P&space;)&space;)}{s&space;(s&plus;12.064)}" target="_blank"><img src="https://latex.codecogs.com/gif.latex?A(s)=&space;\frac{18.69&space;K_P&space;(s&plus;K_I/K_P&space;)&space;)}{s&space;(s&plus;12.064)}" title="A(s)= \frac{18.69 K_P (s+K_I/K_P ) )}{s (s+12.064)}" /></a>


The system that was described was solved in order to calculate the values of the unknown variables. I have found that the values **K~p~ = 2** and **K~I~ = 51.077** satisfy our requirements.

At this point we can calculate the values of the parameters:


- <a href="https://www.codecogs.com/eqnedit.php?latex=a=T_i=K_P/K_I&space;=0.039" target="_blank"><img src="https://latex.codecogs.com/gif.latex?a=T_i=K_P/K_I&space;=0.039" title="a=T_i=K_P/K_I =0.039" /></a>

- <a href="https://www.codecogs.com/eqnedit.php?latex=K=&space;\frac{K_P}{F*a*K_e}=\frac{2}{0.039&space;F{1}}=51.07" target="_blank"><img src="https://latex.codecogs.com/gif.latex?K=&space;\frac{K_P}{F*a*K_e}=\frac{2}{0.039&space;F{1}}=51.07" title="K= \frac{K_P}{F*a*K_e}=\frac{2}{0.039 F{1}}=51.07" /></a>







### Simulink

<p align="center">
<img src="images/5.jpg">
</p>



The reference signal was fed using the tool **signal Builder** and the following function:

<p align="center">
<img src="images/6.jpg">
</p>


With the help of tool **Data Inspector** we can see that our system meets the requirements:

<p align="center">
<img src="images/7.jpg" width = "800">
</p>







To reduce rise time and steady state error the gains went through the process of **comparative tuning**. The value of **K** and **K~e~** was reduced, while the value of **a** was increased.



<p align="center">
<img src="images/8.jpg">
</p>



Observing the Data Inspector is clear that rise time and elevation were significantly reduced.



<p align="center">
<img src="images/9.jpg">
</p>




### Rule Viewer

At this point we will examine the output of the system, when input is fed with the rule **IF e is PS AND Δe is NM\. **

<p align="center">
<img src="images/10.jpg">
</p>




### Surface of output in respect to input

Function **gensurf** was used to produce a graphical relationship between input and output. As output for each fuzzy set is considered its middle point, because of the COS defuzzifier.

<p align="center">
<img src="images/11.jpg">
</p>





## *Scenario 2*

The signal stands for the speed of a train. For this reason it is essential to ensure the zero elevation of the output signal. The tuning of the gains leads to the following circuit.



### Simulink

<p align="center">
<img src="images/12.jpg">
</p>

The reference signal has a trapezoidal form, using the signal builder:



<p align="center">
<img src="images/13.jpg">
</p>


With the help of tool **Data Inspector** we can see that our system meets the requirements:



<p align="center">
<img src="images/14.jpg">
</p>





## *Scenario* 3

The hypothesis of this scenario is that we have a non zero T~L~ that stands for a disturbance.

<p align="center">
<img src="images/15.jpg">
</p>

Our controller has to observe this disturbance and reject it. The goal of this scenario is to compare the functionality of a **Fuzzy PI Controller** and a **Conventional PI Controller**.



### Simulink

The two different controllers were embodied to the initial circuit, in order to compare their responses.

<p align="center">
<img src="images/16.jpg">
</p>

<p align="center">
<img src="images/17.jpg">
</p>



With the help of tool **Data Inspector** we can see the responses:



<p align="center">
<img src="images/18.jpg">
</p>







## Conclusion

It is obvious that the **Fuzzy PI Controller** behaves more efficient than the  **Conventional PI Controller**. Not only the rise time is significantly smaller, but also it succeeds a better disturbance rejection. As we can see the gain of the disturbance is: 

<a href="https://www.codecogs.com/eqnedit.php?latex=20&space;log⁡(164/150)=0.77<20dB" target="_blank"><img src="https://latex.codecogs.com/gif.latex?20&space;log⁡(164/150)=0.77<20dB" title="20 log⁡(164/150)=0.77<20dB" /></a>
