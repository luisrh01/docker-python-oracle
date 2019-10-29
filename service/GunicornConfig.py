#An example gunicorn configuration file can be found at https://github.com/benoitc/gunicorn/blob/master/examples/example_config.py
#A list of all the values that can be configured can be found at http://docs.gunicorn.org/en/stable/settings.html

import multiprocessing

workers = 4
accesslog = 'log.txt'
