function [b,screensize] = picturePreview(fpath)
%picturePreview����������ʾͼƬ��Ԥ��
%������ͼƬ��ȫ�ƣ�ͼƬλ��+ͼƬ��+ͼƬ��׺
%����Ƕ���ͼƬ�����Ԥ������
b=imread(fpath);                                          
f1=figure(1);
screensize=get(0,'screensize');
set(f1, 'NumberTitle', 'off','name','ԭͼƬ','Position', [10,screensize(4)/9,screensize(3)/1.8,screensize(3)/1.8*3/4]);
axis normal;
imshow(b,'initialmagnification','fit','Border','tight');