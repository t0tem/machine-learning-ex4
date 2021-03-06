function [J grad] = nnCostFunction(nn_params, ...
                                   input_layer_size, ...
                                   hidden_layer_size, ...
                                   num_labels, ...
                                   X, y, lambda)
%NNCOSTFUNCTION Implements the neural network cost function for a two layer
%neural network which performs classification
%   [J grad] = NNCOSTFUNCTON(nn_params, hidden_layer_size, num_labels, ...
%   X, y, lambda) computes the cost and gradient of the neural network. The
%   parameters for the neural network are "unrolled" into the vector
%   nn_params and need to be converted back into the weight matrices. 
% 
%   The returned parameter grad should be a "unrolled" vector of the
%   partial derivatives of the neural network.
%

% Reshape nn_params back into the parameters Theta1 and Theta2, the weight matrices
% for our 2 layer neural network
Theta1 = reshape(nn_params(1:hidden_layer_size * (input_layer_size + 1)), ...
                 hidden_layer_size, (input_layer_size + 1));

Theta2 = reshape(nn_params((1 + (hidden_layer_size * (input_layer_size + 1))):end), ...
                 num_labels, (hidden_layer_size + 1));

% Setup some useful variables
m = size(X, 1);
         
% You need to return the following variables correctly 
J = 0;
Theta1_grad = zeros(size(Theta1));
Theta2_grad = zeros(size(Theta2));

% ====================== YOUR CODE HERE ======================
% Instructions: You should complete the code by working through the
%               following parts.
%
% Part 1: Feedforward the neural network and return the cost in the
%         variable J. After implementing Part 1, you can verify that your
%         cost function computation is correct by verifying the cost
%         computed in ex4.m
%
% Part 2: Implement the backpropagation algorithm to compute the gradients
%         Theta1_grad and Theta2_grad. You should return the partial derivatives of
%         the cost function with respect to Theta1 and Theta2 in Theta1_grad and
%         Theta2_grad, respectively. After implementing Part 2, you can check
%         that your implementation is correct by running checkNNGradients
%
%         Note: The vector y passed into the function is a vector of labels
%               containing values from 1..K. You need to map this vector into a 
%               binary vector of 1's and 0's to be used with the neural network
%               cost function.
%
%         Hint: We recommend implementing backpropagation using a for-loop
%               over the training examples if you are implementing it for the 
%               first time.
%
% Part 3: Implement regularization with the cost function and gradients.
%
%         Hint: You can implement this around the code for
%               backpropagation. That is, you can compute the gradients for
%               the regularization separately and then add them to Theta1_grad
%               and Theta2_grad from Part 2.
%


% mapping vector y
% elegant way from tutorial of Prog.ex.4
%yv = [1:num_labels] == y; % class 'logical'

% another elegant way with diagonal matrix
yv = eye(num_labels)(y,:); % class 'double'

% forward propagation

a1 = [ones(m, 1) X]; %adding bias unit to input layer
z2 = a1*Theta1';
a2 = sigmoid(z2); % activating 2nd (hidden) layer
a2 = [ones(size(a2, 1), 1) a2]; %adding bias unit to hidden layer
z3 = a2*Theta2';
a3 = sigmoid(z3); % activating output layer
h = a3; % hypothesis

% cost function

% one way to have unregularized cost function - elementwise multiplication 
% of matrices of y and h. and then summing by columns and by rows
%J = -1/m * (sum(sum(yv.*log(h))) + sum(sum((1-yv).*log(1-h))));

% another way from here
% https://www.coursera.org/learn/machine-learning/discussions/all/threads/AzIrrO7wEeaV3gonaJwAFA?sort=createdAtAsc&page=1
J = -1/m * (trace(yv'*log(h)) + trace((1-yv)'*log(1-h))); 
% trace(A) is sum(diag(A)). we're multiplying matrices (transposing left one first)
% and then summing diagonal elements of the result. apparently it's the same as
% above sum(sum(...)) of elementwise multiplication

% adding regularization to cost function
J +=  lambda/(2*m) * (sum(sum(Theta1(:, 2:end).^2)) + ...
      sum(sum(Theta2(:, 2:end).^2)));

% back propagation

Delta1 = zeros(size(Theta1));
Delta2 = zeros(size(Theta2));

for i = 1:m, % for every example
  % feeding forward
  a1 = X(i,:)'; % activating input layer
  a1 = [1 ; a1]; % adding bias unit
  z2 = Theta1*a1;
  a2 = sigmoid(z2); % activating 2nd (hidden) layer
  a2 = [1 ; a2]; % adding bias unit
  z3 = Theta2*a2;
  a3 = sigmoid(z3);
  
  % feeding back
  d3 = a3 - ([1:num_labels] == y(i))'; % alt. " -yv(i,:)'; "
  d2 = Theta2(:,2:end)'*d3.*sigmoidGradient(z2);
  
  Delta2 += d3*a2';
  Delta1 += d2*a1'; 
  
end;

% unregularized gradient
Theta1_grad = 1/m*Delta1;
Theta2_grad = 1/m*Delta2;

% calculating regularization for gradient (excl. bias term - i.e. 1st column)
reg1 = lambda/m*Theta1(:,2:end);
reg2 = lambda/m*Theta2(:,2:end);

% adding regularization to gradient (excl. bias term - i.e. 1st column)
Theta1_grad(:,2:end) += reg1;
Theta2_grad(:,2:end) += reg2;


% -------------------------------------------------------------

% =========================================================================

% Unroll gradients
grad = [Theta1_grad(:) ; Theta2_grad(:)];


end
