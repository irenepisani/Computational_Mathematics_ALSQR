%% Stopping Criteria 
%
%% Syntax
%
%
%% Description
%
%
%% Parameters 
%
%
%% Examples
%
%
%% ---------------------------------------------------------------------------------------------------
function [U, V] = OptSolver (A, k, stop_condition, intial_V, verbosity)

%m = size(A,1);
n = size(A,2);

if nargin > 5 
    V = initial_V;
else 
    V = Initialize_V(n, k); 
end

if nargin > 6 && verbosity
  verbose = 1;
else
  verbose = 1;
end

% fix max number of epoch
max_epoch = stop_condition(1);

%residual_step_1 = zeros(max_epoch,1);
%residual_step_2 = zeros(max_epoch,1);

%convergence_u_story = zeros(max_epoch,1);
%convergence_v_story = zeros(max_epoch,1);

%u_norm_story = zeros(max_epoch,1);
%v_norm_story = zeros(max_epoch,1);

%u_err_prev = 1;
%v_err_prev = 1;

% early stooping parameter;
local_stop = 0; 
l = max_epoch;
for i = 1:max_epoch
    
    [U,u_err] = OptApproximateU(A, V);
    [V,v_err] = OptApproximateV(A, U);

    %residual_step_1(i) = u_err/norm(A, "fro");
    %residual_step_2(i) = v_err/norm(A, "fro");

    %convergence_u_story(i) = u_err/u_err_prev;
    %convergence_v_story(i) = v_err/v_err_prev;

    %u_norm_story(i) = norm(U,"fro");
    %v_norm_story(i) = norm(V,"fro");

    %u_err_prev = u_err;
    %v_err_prev = v_err;
    
    % ---> Stopping criteria 
    if i>1
        rel_err = v_err/norm(A, "fro");
        temp = U_prev*V_prev';

        convergence_rate = norm(temp - U*V', "fro") / norm(temp, "fro");
        [stop, local_stop] = StoppingCriteria(i, stop_condition, rel_err, convergence_rate, local_stop);
        if stop == true
            l = i; 
            break
        end
    end

    U_prev = U;
    V_prev = V;
   
end

%{

if verbose
    Plotter([residual_step_1 residual_step_2], [convergence_u_story convergence_v_story], [u_norm_story v_norm_story ])
end

last_cr_v = convergence_v_story(l);
last_rs_v = residual_step_2(l);

%}