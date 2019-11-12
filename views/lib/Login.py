# -*- coding: UTF-8 -*-

from functools import wraps
from flask import session,url_for, redirect,logging

# 登录状态检查
def logincheck(f):
    @wraps(f)
    def wrapper(*args, **kwargs):
        try:
            return f(*args, **kwargs)
        except Exception, e:
            print e
            return redirect(url_for('Error'))

    return wrapper
