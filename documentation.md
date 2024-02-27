# T02 Hands-on Task 2: Stopwatch on Basys3  
## **Stopwatch**
Our group was tasked to implement the given stopwatch code on the Basys-3 board and ensure that it functioned at a reasonable frequency and had a time display which shows the elapsed time in minutes and seconds.  
## **Frequency**  
A video was separately submitted to show that our stopwatch operated in sync with a phone stopwatch. The Basys3 stopwatch  display updated every 1 second and the reset button also functioned properly.   
## **Time display**
An additional case was made to display a decimal point to separate minutes and seconds. 

![photo1709000259](https://github.com/stephlovesfries/T02-Stopwatch-on-Basys3/assets/115708694/24a6e10a-5c3f-4e52-a898-f09cf1ca5943)

Once the second decade counter reaches 6, it resets to 0, the dp register is set to 1 and the minute counter is advanced by 1.  A video was submitted separately to show this implementation. 

![photo1709000302](https://github.com/stephlovesfries/T02-Stopwatch-on-Basys3/assets/115708694/78e1d045-fd9a-4de5-a605-ab97cf9eec66)

![photo1709000724](https://github.com/stephlovesfries/T02-Stopwatch-on-Basys3/assets/115708694/a4f4e243-935b-4daa-9986-11bd2fc1dff9)

## **Pause/Resume Optional Task**
Using both switch and buttons to implement a pause/resume function, our group designed two different approaches. Videos of both approaches were submitted separately.
### **Approach 1: Start, Pause, and Resume button**
The start button was declared in the stopwatch module. All three functions: start, pause, and resume, would be initiated by the start button. If the start button is pressed, the counter would begin counting. When it is pressed again, the counter would pause. If pressed once more, the counter would resume. LEDs were also declared as outputs for debugging purposes. 

![photo1708992302](https://github.com/stephlovesfries/T02-Stopwatch-on-Basys3/assets/115708694/f89abc26-90cf-4373-9ece-17bc3a0124ec)

![photo1708992302 (1)](https://github.com/stephlovesfries/T02-Stopwatch-on-Basys3/assets/115708694/ebf827b1-a648-467f-a3c3-e917b628e91c)

The running function stops the counter by interrupting the clock when the running state is true. When the start button is pressed, the running state is toggled between 1 and 0 to pause and resume the clock. By setting the running function to zero when reset state is true, the value of the clock stays at 0 when the reset button is pressed and the counter only resumes counting once the start button is pressed. 

![photo1708992302 (2)](https://github.com/stephlovesfries/T02-Stopwatch-on-Basys3/assets/115708694/5f8f3ee4-0f80-44dd-a736-33166cf1a9b9)

![photo1708992302 (3)](https://github.com/stephlovesfries/T02-Stopwatch-on-Basys3/assets/115708694/6a8e46a1-a273-4f41-9488-2dc7430b69cd)


### **Approach 2: Start, Pause, and Resume switch**
This is similar to the first approach, except the pause function was mapped to a switch instead of a button (although in the code the switch was assigned the name “btnU”). Unlike a button which constantly needs to be manually pressed down to maintain its state, switches constantly stay in its current state until it is manually flipped, reducing the amount of code needed for a toggling condition.

![Screenshot 2024-02-26 212002](https://github.com/stephlovesfries/T02-Stopwatch-on-Basys3/assets/115708694/55129b02-9930-42cc-8bee-77c36ac9a119)

![Screenshot 2024-02-26 211729](https://github.com/stephlovesfries/T02-Stopwatch-on-Basys3/assets/115708694/313bffb9-4061-4955-bd7e-0001bf888e30)

The stop function is initiated whenever the pause state is true. Once the pause switch is flipped on (pause state is true) and the reset button is pressed, the value of the counter stays at 0 and only begins counting once the pause switch is flipped back off. During counting, once the pause switch is flipped, the stop function is initiated and the counter retains its current value until the pause switch is flipped back off, which resumes the counter. 

![Screenshot 2024-02-26 212720](https://github.com/stephlovesfries/T02-Stopwatch-on-Basys3/assets/115708694/f0317327-39b8-462e-a7a5-47d1813f0352)

## **Challenges and learnings**
Our group was initially challenged when determining which line of code to modify in order to implement the features we want. Furthermore, we were also challenged by the various differences between  the Verilog coding style  and the C++ coding style. By analyzing the given code and running trial and error simulations, our team gained a deeper understanding of Verilog syntax and behavioral modeling in real-life applications.  We also learned how to modify existing Verilog code to implement the features we want in our design. 
