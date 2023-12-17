---
title: Code Sample [^1]
author: Haoliang Hu <huhaoliang@whu.edu.cn>
date: Dec. 15 2023
header-includes:
  - \usepackage[utf8]{inputenc}
  - \usepackage[a4paper, total={8in, 10in}]{geometry}
  - \usepackage{amsthm}
  - \usepackage{float}
  - \usepackage{amsmath, graphicx, booktabs, tabularx, caption, subcaption,amsfonts, bbm}
  - \usepackage{hyperref}
  - \hypersetup{
    colorlinks=true,
    linkcolor=blue,
    filecolor=magenta,      
    urlcolor=cyan
    }
---

## Background

[^1]: I finished this markdown file by `markstat`. The source code is in my github repository, [here](https://github.com/whuhu/)

This sample is my code for a data task. It has 4 parts: \
- Part 0 Initialization \
- Part 1 Data Cleaning \
- Part 2 Data Exploration \
- Part 3 Estimation and Causal Inference \

## 0. Initialization

{{1}}

Summarize the data. I find this data set contains entries of patient flow. The shift duration typically lasts around 9 to 10 hours, and there are rare situations where the shift lasts only 2 hours. And I checked the duplication of the arrive and leave times of patients and found some observations that may appear to be data entry errors as they have exactly the same arrive and leave times, which may result from coding errors of the ED system. In the following analysis, I take them as true data for convenience.

\begin{table}[!htb]
\centering
\begin{tabular}{llll}
\cline{1-4}
Group & Obs  & arrive    &leave \\ \cline{1-4}
1     & 2558 & 03jul1982 07:27:03 & 03jul1982 08:34:46 \\
1     & 2659 & 03jul1982 07:27:03 & 03jul1982 08:34:46 \\
2     & 7905 & 09jun1982 06:11:17 & 09jun1982 08:43:06 \\
2     & 7973 & 09jun1982 06:11:17 & 09jun1982 08:43:06 \\
3     & 2564 & 11jul1982 04:57:33 & 11jul1982 05:25:57 \\
3     & 2710 & 11jul1982 04:57:33 & 11jul1982 05:25:57 \\
4     & 6565 & 13jun1982 10:00:11 & 13jun1982 12:02:31 \\
4     & 6833 & 13jun1982 10:00:11 & 13jun1982 12:02:31 \\
5     & 3563 & 16jun1982 18:25:49 & 16jun1982 21:47:53 \\
5     & 3777 & 16jun1982 18:25:49 & 16jun1982 21:47:53 \\
6     & 7893 & 18jun1982 12:38:47 & 18jun1982 14:54:13 \\
6     & 8632 & 18jun1982 12:38:47 & 18jun1982 14:54:13 \\
7     & 6710 & 24may1982 14:20:20 & 24may1982 15:46:38 \\
7     & 6795 & 24may1982 14:20:20 & 24may1982 15:46:38 \\
8     & 8804 & 28may1982 10:30:29 & 28may1982 11:17:27 \\
8     & 8812 & 28may1982 10:30:29 & 28may1982 11:17:27 \\
9     & 2522 & 29may1982 10:55:13 & 29may1982 15:35:56 \\
9     & 5467 & 29may1982 10:55:13 & 29may1982 15:35:56 \\
10    & 1079 & 30may1982 08:53:35 & 30may1982 10:03:29 \\
10    & 1122 & 30may1982 08:53:35 & 30may1982 10:03:29 \\ \cline{1-4}
\end{tabular}
    \caption{Possible Data Entry Errors}
\end{table}

## 1. Data Cleaning

First I transfer the a.m./p.m. to 24-hours in order to transfer the original datatime format into stata time format. Notably, we should use double here to generate the new stata datatime variable. Finally we get there are \textbf{7.43\%} patients arriving before their physician's shift starts and \textbf{19.01\%} patients discharged after their physician's shift ends.


{{2}}


I transformed all li(measure of fuel consumption) variables into number so that I could fill in the missing values. 
I first filled in the missing values in li and used the value of li to fill in other missing values. 


{{3}}


## 2. Data Exploration

I calculated the average predicted severity by half-hour of patient arrival. The connected plot and trend line does not show obvious connection between hours of arrival and the predicted severity of the patient. To test formally test whether patient severity is or is not predicted by hour of the day, I regressed the pred\_lnlos on the dummies of hour arrival variables. The coefficient plot of dummies shows patients stay shorter at dawn and after lunch and stay longer in the morning. However, the result may result from the limit of usage of some inspect equipment such as CT.


{{4}}


\begin{figure}[!htb]
  \centering
  \includegraphics[width=0.9\textwidth]{C:\Users\huhu\Desktop\Code Task\David Chan Data Task\out\Average_Severity.png}
  \caption{Average Severity by Half-Hour of Patient Arrival}
  \label{}
\end{figure}

\begin{figure}[!htb]
  \centering
  \includegraphics[width=0.9\textwidth]{C:\Users\huhu\Desktop\Code Task\David Chan Data Task\out\Coef_Hours.png}
  \caption{Coefficient of Arrival Hours}
  \label{}
\end{figure}



## 3.Estimation and Causal Inference

(a) I graphed the census variation relative to end of shift as Fig. 3 shows. The census count -- in any census scope, would increase at the beginning of the physician's shift and decreases as the time get closer to his end of shift time. And the patient under care still decreases even the time passed the shift time for 4 hours.

(b) As we have the accurate time of the shift time and the patient arrival time. I construct the lower bound of the census under the criterion that we only take the patients who is under care for the whole hours into account. And I construct the upper bound of the census under the criterion that we counts the patients whoever is under care when he arrives the ED at that hour. At last, the finer census -- I excluded the patients whose arrival time is among the last 15 minutes of the hour or leave time is among the first 15 minutes of the hour. One issue one may addressed is that the physician may arrive at the EP before his scheduled time, which would affects the power of our above analysis. In the mean time, the time between the arrival time and leave time of patients may not be accounted in the care time, they may wait at the waiting room or doing some paper works before the physician's care.

(c) If we have the ED data, we may construct the census of the co-work of more than one physicians, and under this circumstance, they may behavior differently.


{{5}}


\begin{figure}[!htb]
  \centering
  \includegraphics[width=0.9\textwidth]{C:\Users\huhu\Desktop\Code Task\David Chan Data Task\out\Census_Variation.png}
  \caption{Census Variation Relative to End of Shift}
  \label{}
\end{figure}

## 4. Further Analysis

I regressed the length of the stay on the dummies of the physicians, the result shows at the Figure 4, phys\_id=16 is the one who is fastest at discharging patients. The potential threats may be that different physicians in different ED may encounter different types of patients, thus leading to different discharge time. So we can control the expected log length of stay, where length of stay is the difference between leave and arrive, based on patient demographics and medical conditions. The result is robust, physician 16 and 30 are two who are fastest at discharging patients.

Moreover, a potential issue may arising from the fact that the patient may be discharged after the physician's shift time. So we just regress the log length of stay on the dummies of time to shift. The result is still robust to this specification: physician 16 and 30 are two who are fastest at discharging patients.


{{6}}


\begin{figure}[!htb]
  \centering
  \includegraphics[width=0.9\textwidth]{C:\Users\huhu\Desktop\Code Task\David Chan Data Task\out\Coef_phys.png}
  \caption{Coefficient of Physician}
  \label{}
\end{figure}

\begin{figure}[!htb]
  \centering
  \includegraphics[width=0.9\textwidth]{C:\Users\huhu\Desktop\Code Task\David Chan Data Task\out\Coef_phys_control.png}
  \caption{Coefficient of Physician, Controlled for pred\_los}
  \label{}
\end{figure}
