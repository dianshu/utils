#! python3
# coding:utf-8
import os
import shutil
import requests
from datetime import datetime
from urllib.parse import urljoin

from bs4 import BeautifulSoup


class VOAClient:
    base_url_tpl = 'https://www.51voa.com/VOA_Standard_{}.html'

    headers = {
        'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_5) AppleWebKit/537.36 (KHTML, like Gecko) '
                      'Chrome/83.0.4103.97 Safari/537.36'
    }

    def __init__(self, des):
        self.des = des
        self.base_url = self.base_url_tpl.format(datetime.today().day)

        print(f'base_url: {self.base_url}')

        # 如果目录存在，则删除目录
        if os.path.exists(self.des):
            shutil.rmtree(self.des)

        os.mkdir(self.des)

    def get_resp(self, url):
        return requests.get(url, headers=self.headers)

    def get_resp_soup(self, url):
        resp = self.get_resp(url)
        return BeautifulSoup(resp.text, 'html.parser')

    def get_page_urls(self):
        soup = self.get_resp_soup(self.base_url)
        list_div = soup.find(class_='List')

        # 返回包含 mp3 的页面链接
        for a in list_div.find_all('a'):
            yield urljoin(self.base_url, a.attrs['href'])

    def _download_mp3_core(self, page_url):
        soup = self.get_resp_soup(page_url)
        mp3 = soup.find(id='mp3')
        if mp3:
            mp3_url = mp3.attrs.get('href')

            if mp3_url:
                mp3_name = mp3_url.split('/')[-1]

                resp = self.get_resp(mp3_url)
                with open(os.path.join(self.des, mp3_name), 'wb') as mp3_file:
                    mp3_file.write(resp.content)

                print(f'{mp3_name} 下载完成。')

    def download_mp3s(self):
        for page_url in self.get_page_urls():
            self._download_mp3_core(page_url)


if __name__ == '__main__':
    VOAClient('/Users/bai/Downloads/voa').download_mp3s()
