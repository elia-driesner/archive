from curses import A_ALTCHARSET
import cv2
import os
import pygame

pygame.init()

cam = cv2.VideoCapture(0)

cv2.namedWindow("Display", cv2.WINDOW_AUTOSIZE)

clock = pygame.time.Clock()
FPS = 144

textSurfSize = (5000, 5000)
textSurf = pygame.Surface(textSurfSize)

wn = pygame.display.set_mode((1500, 1000), pygame.RESIZABLE)

font = pygame.font.Font('freesansbold.ttf', 35) 

def img_to_ascii(img):
    char = "$@B%&M#*akdqmOQCUXcuxjt\(1}]-+~>i!lI;:,^`'."[::-1]
    ascii_image = []
    img = cv2.resize(img, (int(img.shape[1] / 5), int(img.shape[0] / 5)))
    size = img.shape
    for i in range(0, size[0]):
        ascii_image.append([])
        for j in range(0, size[1]):
            brightness = img[i,j]
            brightness = (0.21 * brightness[0]) + (0.72 * brightness[0]) + (0.07 * brightness[0])
            if brightness > 243:
                ascii_image[i].append(char[0])
            elif brightness > 236:
                ascii_image[i].append(char[1])
            elif brightness > 229:
                ascii_image[i].append(char[2])
            elif brightness > 222:
                ascii_image[i].append(char[3])
            elif brightness > 215:
                ascii_image[i].append(char[4])
            elif brightness > 208:
                ascii_image[i].append(char[5])
            elif brightness > 201:
                ascii_image[i].append(char[6])
            elif brightness > 194:
                ascii_image[i].append(char[7])
            elif brightness > 187:
                ascii_image[i].append(char[8])
            elif brightness > 180:
                ascii_image[i].append(char[9])
            elif brightness > 173:
                ascii_image[i].append(char[10])
            elif brightness > 164:
                ascii_image[i].append(char[11])
            elif brightness > 157:
                ascii_image[i].append(char[12])
            elif brightness > 150:
                ascii_image[i].append(char[13])
            elif brightness > 143:
                ascii_image[i].append(char[14])
            elif brightness > 136:
                ascii_image[i].append(char[15])
            elif brightness > 129:
                ascii_image[i].append(char[16])
            elif brightness > 122:
                ascii_image[i].append(char[17])
            elif brightness > 115:
                ascii_image[i].append(char[18])
            elif brightness > 173:
                ascii_image[i].append(char[19])
            elif brightness > 164:
                ascii_image[i].append(char[20])
            elif brightness > 157:
                ascii_image[i].append(char[21])
            elif brightness > 150:
                ascii_image[i].append(char[22])
            elif brightness > 143:
                ascii_image[i].append(char[23])
            elif brightness > 136:
                ascii_image[i].append(char[24])
            elif brightness > 129:
                ascii_image[i].append(char[25])
            elif brightness > 122:
                ascii_image[i].append(char[26])
            elif brightness > 115:
                ascii_image[i].append(char[27])
            elif brightness > 108:
                ascii_image[i].append(char[28])
            elif brightness > 101:
                ascii_image[i].append(char[29])
            elif brightness > 94:
                ascii_image[i].append(char[30])
            elif brightness > 87:
                ascii_image[i].append(char[31])
            elif brightness > 80:
                ascii_image[i].append(char[32])
            elif brightness > 73:
                ascii_image[i].append(char[33])
            elif brightness > 66:
                ascii_image[i].append(char[34])
            elif brightness > 59:
                ascii_image[i].append(char[35])
            elif brightness > 52:
                ascii_image[i].append(char[36])
            elif brightness > 45:
                ascii_image[i].append(char[37])
            elif brightness > 38:
                ascii_image[i].append(char[38])
            elif brightness > 31:
                ascii_image[i].append(char[39])
            elif brightness > 24:
                ascii_image[i].append(char[40])
            elif brightness > 17:
                ascii_image[i].append(char[41])
            elif brightness < 10 or brightness > 10:
                ascii_image[i].append(char[42])
        
    
    x, y = 0, 0
    
    for row in ascii_image:
        for char in row:  
            text = font.render(char, True, pygame.Color('black'))
            textSurf.blit(text, ((textSurfSize[0] / len(row)) * x, (textSurfSize[1] / len(ascii_image)) * y))
            x += 1
        y += 1
        x = 0
        
os.system('clear')
while True:
    clock.tick(50)
    wn.fill((0, 0, 0))
    textSurf.fill((255, 255, 255))
    ret, frame = cam.read()
    if not ret:
        print("failed to grab frame")
        break
    img_to_ascii(frame)

    k = cv2.waitKey(1)
    if k%256 == 27:
        print("Escape hit, closing...")
        break
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            break
    wn.blit(pygame.transform.scale(textSurf, (1500, 1000)), (0, 0))
    pygame.display.update()

cam.release()