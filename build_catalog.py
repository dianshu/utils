# coding:utf-8
"""
根据当前目录结构，使用 MarkDown 语法生成对应的有层级关系的列表
下载地址为 https://github.com/dianshu/utils/blob/master/build_catalog.py
"""
import os
from urllib.parse import quote


def _generate_catalog(_dir, depth, skip=False):
    """
    递归生成当前目前文件夹的目录结构
    :param _dir: str 当前文件夹相对初始目录的地址
    :param depth: int 当前文件夹相对初始目录的深度，用于生成对应的缩进
    :param skip: boolean 是否跳过对当前文件夹自身目录项的生成
    :return: 
    """
    # 生成当前文件夹自身目录项
    if not skip:
        print(generate_catalog_item(_dir, depth))
        depth += 1
    
    # 针对当前文件夹内部文件和子文件夹，生成目录项
    for name in sorted(os.listdir(_dir)):
        # 屏蔽掉各种配置文件
        if name.startswith('.') or name.startswith('_'):
            continue

        # 屏蔽掉 README.md SUMMARY.md img
        if name in ['README.md', 'SUMMARY.md', 'img']:
            continue

        path = os.path.join(_dir, name)
        # 文件直接生成对应的目录项
        if os.path.isfile(path) and path.endswith('.md'):
            print(generate_catalog_item(path, depth))
        # 递归处理子目录
        elif os.path.isdir(path):
            _generate_catalog(path, depth)


def generate_catalog_item(path, depth):
    # 分离路径和文件名
    __, name = os.path.split(path)
    # 去除文件名的后缀
    name, __ = os.path.splitext(name)
    path = quote(path)
    return f'{"  " * depth}- [{name}]({path})'


def generate_catalog():
    _generate_catalog('.', 0, skip=True)


if __name__ == '__main__':
    generate_catalog()
