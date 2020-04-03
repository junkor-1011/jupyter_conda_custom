ISSUE
=======

------

- `docker run` option
    - HOST-OS側のコマンドラインからストップ出来ない

```Bash
$ docker stop jupyter_conda_custom_amazoncorretto8_8889
Error response from daemon: cannot stop container: jupyter_conda_custom_amazoncorretto8_8889: Cannot kill container cefc7834dfef401cece6b5a9f4569082604df1c8ad4be2990b9daacfb8e1da5c: unknown error after kill: runc did not terminate sucessfully: container_linux.go:388: signaling init process caused "permission denied"
```


- module error(`conda`)

```
[W 16:45:05.188 LabApp] Error loading server extension ipyparallel.nbextension
    Traceback (most recent call last):
      File "/opt/conda/lib/python3.7/site-packages/notebook/notebookapp.py", line 1670, in init_server_extensions
        mod = importlib.import_module(modulename)
      File "/opt/conda/lib/python3.7/importlib/__init__.py", line 127, in import_module
        return _bootstrap._gcd_import(name[level:], package, level)
      File "<frozen importlib._bootstrap>", line 1006, in _gcd_import
      File "<frozen importlib._bootstrap>", line 983, in _find_and_load
      File "<frozen importlib._bootstrap>", line 953, in _find_and_load_unlocked
      File "<frozen importlib._bootstrap>", line 219, in _call_with_frames_removed
      File "<frozen importlib._bootstrap>", line 1006, in _gcd_import
      File "<frozen importlib._bootstrap>", line 983, in _find_and_load
      File "<frozen importlib._bootstrap>", line 965, in _find_and_load_unlocked
    ModuleNotFoundError: No module named 'ipyparallel'
```
