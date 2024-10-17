from PIL import Image
import numpy as np

def convert_to_12bit_rgb_binary(image_path):
    img = Image.open(image_path).convert("RGB")
    img_array = np.array(img)
    img_4bit = (img_array // 16).astype(np.uint8) 
    binary_strings = []
    
    for pixel in img_4bit.reshape(-1, 3): 
        r, g, b = pixel
        rgb_12bit = (r << 8) | (g << 4) | b 
        binary_str = f'{rgb_12bit:012b}'
        binary_strings.append(binary_str)
    
    return binary_strings

def format_binary_output(binary_strings):
    formatted_output = "memory_initialization_radix=2;\nmemory_initialization_vector=\n"
    string = ""
    count = 0
    x = 1 # 192
    for i in range(0, len(binary_strings)):
        string = string + binary_strings[i]
        if((i + 1) % x == 0):
            # print(len(string))
            if len(string) < 12 * x:
                string = string.ljust(12 * x, '0') 
            formatted_output = formatted_output + string + ',\n'
            string = ""
            count = count + 1
    if(string != ""):
        string = string.ljust(12 * x, '0') 
        formatted_output = formatted_output + string
        count = count + 1
    print(count)
    return formatted_output

s = int(input("Enter w : "))
binary_image_strings = convert_to_12bit_rgb_binary(f"pics/bluba_{s}.png")

formatted_output = format_binary_output(binary_image_strings)

with open(f"COES/bluba_{s}.coe", "w") as f:
    f.write(formatted_output)
