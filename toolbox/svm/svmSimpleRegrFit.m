function [model, svi] = svmSimpleRegrFit(K,y,e,C)
% Support vector regression
% One norm epsilon insensitive loss funciton

% Based on code by Steve Gunn
% http://www.isis.ecs.soton.ac.uk/resources/svminfo/

n = length(y);
H = [K -K; -K K];
f = [(e*ones(n,1) - y); (e*ones(n,1) + y)];
A = []; b = [];
Aeq = [ones(1,n) -ones(1,n)];
beq = 0;   
lb = zeros(2*n,1);    
ub = C*ones(2*n,1);   

a = quadprog(H,f,A,b,Aeq,beq,lb,ub);
alpha =  a(1:n) - a(n+1:2*n);

epsilon = C*1e-6;
svi = find( abs(alpha) > epsilon ); % support vectors

% find bias from average of support vectors with interpolation error e
% SVs with interpolation error e have alphas: 0 < alpha < C
svii = find( abs(alpha) > epsilon & abs(alpha) < (C - epsilon));
if ~isempty(svii)
   bias = (1/length(svii))*sum(y(svii) - e*sign(alpha(svii)) - K(svii,svi)*alpha(svi));
else
   fprintf('No support vectors with interpolation error e - cannot compute bias.\n');
   bias = (max(y)+min(y))/2;
end
model.bias = bias;
model.alpha = alpha;
end