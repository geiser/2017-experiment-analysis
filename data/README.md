


## 

- CSV-file with information about programming problem tasks ([FullScaleStudies-Legend-VPL.csv](FullScaleStudies-Legend-VPL.csv))
- CSV-file with information about programming problem tasks 



### CSV-file with information from VPL Moodle plugin

File: [FullScaleStudies-SourceMoodle-VPL.csv](FullScaleStudies-SourceMoodle-VPL.csv) 

| Column | Description |
|--------|----------|
| UserID | Integer as user identification to differentiate students on the empirical studies |
| NroUSP | Integer as students identification to differentiate students on the school |
| startPX | Epoch unix time stamp in which the student with **`UserID`** started to solve the programming problem tasks with identification **`PX`** |
| corrPX | Correctness score of the programming problem task with identification **`PX`** |
| exatPX | Exact effective time in seconds spent by the student with **`UserID`** to solve the programming problem task with identification **`PX`**. Effective time is the window-time in seconds dedicated by the student inside the VPL editor. |
| PXs0 | Guttman-based score for the programming problem task with identification **`PX`** and rule **_`s0`_**. |
| PXs1 | Guttman-based score for the programming problem task with identification **`PX`** and rule **_`s1`_**. |
| PXs2 | Guttman-based score for the programming problem task with identification **`PX`** and rule **_`s2`_**. |
| PXs3 | Guttman-based score for the programming problem task with identification **`PX`** and rule **_`s3`_**. |


#### Guttman-structure scoring rules

rule **_`s0`_**: _score_(_Q_)
   - 0: when the solution is incorrect `(Q=0)`, and the solving time is irrelevant
   - 1: when the solution is correct `(Q=1)`, and the solving time is irrelevant


rule **_`s1`_**: _score_(_Q x T50_)
 - `(0,x) = 0`: when the solution is incorrect `(Q=0)` and the solving time is irrelevant
 - `(1,0) = 1`: when the solution is correct `(Q=1)` and the solving time is greater than the median `(t>T55)`
 - `(1,1) = 2`: when the solution is correct `(Q=1)` and the solving time is less than the median `(t<T50)`.


rule **_`s2`_**: _score_(_Q x T66 x T33_)
 - `(0,x,x) = 0`: when the solution is incorrect `(Q=0)` and the solving time is irrelevant
 - `(1,0,x) = 1`: when the solution is correct `(Q=1)` and the solving time is greater than 66-th percentile `(t>T66)`
 - `(1,1,0) = 2`: when the solution is correct `(Q=1)` and the solving time is greater than 33-th percentile `(t>T33)`
 - `(1,1,1) = 3`: when the solution is correct `(Q=1)` and the solving time is less than 33-th percentile `(t<T33)`


rule **_`s3`_**: _score_(_Q x T75 x T50 x T25_)
 - `(0,x,x,x) = 0`: when the solution is incorrect `(Q=0)`, and the solving time is irrelevant
 - `(1,0,x,x) = 1`: when the solution is correct `(Q=1)`, and the solving time is greater than 75-th percentile `(t>T75)`
 - `(1,1,0,x) = 2`: when the solution is correct `(Q=1)` and the solving time is greater than the median `(t>T50)`
 - `(1,1,1,0) = 3`: when the solution is correct `(Q=1)`, and the solving time is greater than 25-th percentile `(t>T25)`
 - `(1,1,1,1) = 4`: when the solution is correct `(Q=1)`, and the solving time is less than 25-th percentile `(t<T25)`


## Fixing `ERROR 2006 (HY000): MySQL server has gone away`?

```shell
mysql -u root -p
# enter password

mysql > SET GLOBAL max_allowed_packet=1073741824;
```

and add to `/etc/my.cnf`:

```
# /etc/my.cnf
max_allowed_packet=128M



