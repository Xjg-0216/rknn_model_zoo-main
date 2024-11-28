

import shutil

import os
import random

# 设置文件夹路径和目标文件
imgs_path = "/home/xujg/train"  # 图像文件夹路径
output_file = "/home/xujg/code/rknn_model_zoo-main/datasets/newdataset/sampled_images.txt"  # 输出的txt文件名
save_path = "/home/xujg/code/rknn_model_zoo-main/datasets/newdataset/subsample"
# 采样数量
sample_num = 60
os.makedirs(save_path, exist_ok=True)
# 获取文件夹中的所有图像文件
image_files = [f for f in os.listdir(imgs_path) if os.path.isfile(os.path.join(imgs_path, f))]

# 确保文件夹中有足够的图像
if len(image_files) < sample_num:
    print(f"文件夹中的图像不足{sample_num}个，当前有{len(image_files)}个图像。")
else:
    # 随机选择sample_num个图像
    sampled_images = random.sample(image_files, sample_num)

    # 将图像名称写入txt文件
    with open(output_file, 'w') as f:
        for img in sampled_images:
            shutil.copy(os.path.join(imgs_path, img), os.path.join(save_path, img))
            f.write('./subsample/' + img + '\n')

    print(f"已随机选择{sample_num}个图像，并将其名称保存到{output_file}。")

