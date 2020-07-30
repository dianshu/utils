# coding:utf-8
”“”
根据当前目录结构，使用 MarkDown 语法生成对应的有层级关系的列表
“”“
import os
from urllib.parse import quote


def generate_catalog(_dir, depth):
    print(generate_catalog_item(_dir, depth))
    depth += 1
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
            generate_catalog(path, depth+1)


def generate_catalog_item(path, depth):
    __, name = os.path.split(path)
    path = quote(path)
    return f'{"  " * depth}- [{name}]({path})'


if __name__ == '__main__':
    generate_catalog('.', 0)
