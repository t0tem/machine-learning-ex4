vImage1 = imageTo20x20Gray('Pic1.png', 50, 0);

displayData(vImage1);

% NN has to be trained already, i.e. optimozed Theta1 & Theta2 in memory

predict(Theta1, Theta2, vImage1)
