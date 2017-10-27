function [b,screensize] = picturePreview(fpath)
%picturePreview函数用来显示图片的预览
%输入是图片的全称，图片位置+图片名+图片后缀
%输出是读的图片矩阵和预览开关
b=imread(fpath);                                          
f1=figure(1);
screensize=get(0,'screensize');
set(f1, 'NumberTitle', 'off','name','原图片','Position', [10,screensize(4)/9,screensize(3)/1.8,screensize(3)/1.8*3/4]);
axis normal;
imshow(b,'initialmagnification','fit','Border','tight');