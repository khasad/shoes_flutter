import base64

def image_to_base64(image_path):
    with open(image_path, "rb") as image_file:
        encoded_string = base64.b64encode(image_file.read()).decode('utf-8')
    return encoded_string

# Ganti 'path/to/your/adidas_ultraboost.png' dengan jalur sebenarnya ke file gambar Anda
# Misalnya: 'C:/Users/NamaAnda/Documents/adidas_ultraboost.png' atau './adidas_ultraboost.png' jika di folder yang sama
image_file_path = 'path/to/your/adidas_ultraboost.png'
base64_string = image_to_base64(image_file_path)
print(base64_string)