
## 



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



