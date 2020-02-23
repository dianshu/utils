# coding:utf-8
import os
import shutil
from itertools import zip_longest

import img2pdf
import requests
from bs4 import BeautifulSoup
from PIL import ImageEnhance, Image
from pdf2image import convert_from_path


class ImgAndPdf(object):

    @staticmethod
    def valid_img_format():
        return ['jpg', 'jpeg', 'png', 'bmp']

    @staticmethod
    def check_dir(_dir):
        if os.path.exists(_dir):
            shutil.rmtree(_dir)
        os.makedirs(_dir)

    @staticmethod
    def img_names(_dir):
        names = filter(lambda x: os.path.splitext(x)[1][1:].lower() in ImgAndPdf.valid_img_format(), os.listdir(_dir))
        names = sorted(list(names))
        return names

    @staticmethod
    def prepare_imgs(_dir):
        ImgAndPdf.check_dir(_dir)
        
        url = URL
        
        resp = requests.get(url)
        text = resp.text
        
        soup = BeautifulSoup(text, 'html.parser')
        div = soup.find(id='js_content')

        for i, img in enumerate(div.find_all('img')):
            src = img.attrs['data-src']
            _format = img.attrs['data-type']
            if _format not in ImgAndPdf.valid_img_format():
                continue
            resp = requests.get(src)
            path = os.path.join(_dir, '{i:03d}.{fmt}'.format(i=i, fmt=_format))
            with open(path, 'wb') as img_file:
                img_file.write(resp.content)
            print(path)

    def enhance_imgs_to_file(self, src_dir, des_dir, factor=1):
        """
        将原始图片进行增强后保存
        """
        if factor == 1:
            return

        self.check_dir(des_dir)

        for src_img_name in self.img_names(src_dir):
            src_img_path = os.path.join(src_dir, src_img_name)
            src_img = Image.open(src_img_path, 'r')

            enhance_brightness = ImageEnhance.Brightness(src_img)
            enhance_img = enhance_brightness.enhance(factor)
            enhance_img.save(os.path.join(des_dir, src_img_name))

            src_img.close()

    def concatenate_imgs_to_file(self, src_dir, des_dir):
        """
        将两张图片旋转后合并为一张图片
        """
        self.check_dir(des_dir)

        def two_imgs(_dir):
            img_names = self.img_names(_dir)
            for img_name_lower, img_name_upper in zip_longest(img_names[::2], img_names[1::2], fillvalue=None):
                img_lower = Image.open(os.path.join(_dir, img_name_lower), 'r')
                if img_name_upper is None:
                    img_upper = Image.new('RGB', img_lower.size, (255, 255, 255))
                else:
                    img_upper = Image.open(os.path.join(_dir, img_name_upper), 'r')
                yield img_lower, img_upper

        def standard_img(_img):
            img = _img.resize((int(_img.width * 1488.0 / _img.height) + 1, 1488), Image.ANTIALIAS)
            img = img.transpose(Image.ROTATE_90)
            return img

        for i, (src_img_lower, src_img_upper) in enumerate(two_imgs(src_dir)):
            des_img = Image.new('RGB', (1488, 2106), (255, 255, 255))
            des_img.paste(standard_img(src_img_upper), box=(0, 0))
            des_img.paste(standard_img(src_img_lower), box=(0, 2106 // 2))
            des_img.save(os.path.join(des_dir, '{:0>3}.{}'.format(i, src_img_lower.format.lower())))

            src_img_lower.close()
            src_img_upper.close()

    def merge_imgs_into_pdf(self, img_dir, pdf_path='a.pdf'):
        """
        将图片合并为 PDF
        :param pdf_path: str 生成的 pdf 地址
        """
        # 横
        a4input = (img2pdf.mm_to_pt(210), img2pdf.mm_to_pt(297))

        # 竖
        # a4input = (img2pdf.mm_to_pt(297), img2pdf.mm_to_pt(210))

        layout_fun = img2pdf.get_layout_fun(a4input)
        img_paths = [os.path.join(img_dir, img_name) for img_name in self.img_names(img_dir)]
        with open(pdf_path, 'wb') as pdf_file:
            pdf_file.write(img2pdf.convert(img_paths, layout_fun=layout_fun))

    def split_pdf_into_imgs(self, pdf_path, img_dir):
        """
        将 PDF 分割成 图片 JPG
        """
        self.check_dir(img_dir)
        convert_from_path(pdf_path, output_folder=img_dir, fmt='jpg')


if __name__ == '__main__':
    client = ImgAndPdf()

    # 将 PDF 拆分为 图片
    client.split_pdf_into_imgs('a.pdf', 'imgs')

    # 从网页端下载图片
    client.prepare_imgs('imgs')
    
    # 拼接
    client.concatenate_imgs_to_file('imgs', 'concatenate_imgs')

    # 增强
    client.enhance_imgs_to_file('concatenate_imgs', 'enhance_imgs', 1.2)

    # 合成 PDF
    client.merge_imgs_into_pdf('enhance_imgs', 'b.pdf')
