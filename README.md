# 模块说明


## imgs_and_pdf

### 用途
在图片和 PDF 之间进行转换

### 依赖
1. popper
    - Centos7.6 `yum install poppler-utils.x86_64`
2. Python 库
    - `pip install pdf2image img2pdf bs4`


## download_voa

### 用途
根据当天日期下载 51voa 常速英语指定页面的音频

### 依赖
1. Python 库
    - `pip install bs4`

## build_catalog
根据当前目录结构，使用 MarkDown 语法生成对应的有层级关系的列表

## setup_distcc_and_ccache

### 用途
初始化 Ubuntu 的 distcc 和 ccache，用于加速编译
  
## xiaohongshu

### 用途
清洗后裔采集器采集到的原始数据

### 依赖
1. Python 库
    - `pip install openpyxl`
