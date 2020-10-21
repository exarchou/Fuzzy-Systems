# Group 2

The purpose of this project is the design of a **Fuzzy Logic Controller** for the control of the motion of a virtual 2D car, in order to avoid static obstacles. Sensors measuring vertical and horizontal distance from obstacles are available to achieve this goal. Vehicle's speed is constant and equal to 0.05 m/s. Given the distances and the angle **theta** as inputs the controller has to compute the alteration of the angle **delta theta**.

<p align="center">
<img src="images/1.png" width = 380>
</p>



 The fuzzy sets of the variables are given below:

<p align="center">
<img src="images/2.png">
</p>



## Fuzzy Logic Controller

The **Fuzzy Logic Toolbox**, offered by MATLAB, will be used for the implementation of the Fuzzy Logic Controller with the following features: 

- Implementation operator **Larsen**
- Operator AND through **max**
- Composition operator **max-min**
- Defuzzifier Center of Averages, **COA**



<p align="center">
<img src="images/3.png" width = 450>
</p>



Inputs and Outputs have the following **membership functions**:

<p align="center">
<img src="images/4.png">
</p>



The next step is the design of the **Fuzzy Rules Base**, which includes sentences with the form:

<p align="center">
<img src="images/5.png" width = "560">
</p>

Rules were designed with respect to Vehicle's distances from obstacles and initial angle theta.





## Route Planning

The membership functions of the inputs and outputs are printed:

<p align="center">
<img src="images/6.png" width = "570">
</p>

The function **distance_sensor** is used to calculate the distances from obstacles. Those distances in combination with initial theta angle are the arguments of a MATLAB built-in **evalfis** function. The output **delta theta** is then added to the previous **theta** value to compute the new angle. The computation of the path continues, until our vehicle cross the boundaries of the map or approach its goal. In the following graphs we can see the results of the computation for different initial theta values:



<p align="center">
<img src="images/7.png">
</p>



<p align="center">
<img src="images/8.png" width = "390">
</p>





## Optimized Controller

Although the previous analysis succeeds in approaching the goal position fair enough, we can still optimize our system's behavior. For this reason the fuzziness of the membership functions will be reduced as following:

<p align="center">
<img src="images/9.png">
</p>



The route to the goal position is obviously improved:

<p align="center">
<img src="images/10.png">
</p>



<p align="center">
<img src="images/11.png" width = "390">
</p>





## Conclusion

By reducing the fuzziness of our fuzzy variables, a better approach of the goal position is succeeded. To do so, the membership functions have to be "crispier".