%% Execute Experiment Time
%
% This function is defined for performing time efficiency experiments with
% respect to:
% 1) Our ThinQR vs. lecture course FullQR vs. matlab ThinQR
% 2) Our ALS-QR vs. matlab Truncated SVD
%
%% Syntax
%
% [] = ExecuteExperiment_Time(values)
%
%% Description
%
% Given all the possible parameter values  this function compute all possible
% combinations of them and solve the problem with respect to each
% combinations.  All the results obtained with each combinations are saved
% in a final 2 csv document : 
% - {...}_experiments_Properties.csv : contains info about performed combination and the corresponding paramter values
%    - if starting problem is 1) then the file will contain
%    (id, m_size, n_size)
%    - if starting problem is 2) then the file will contain
%    (id, m_size, n_size, k_rank, density, lambda_u, lambda_v)
% - {...}_experiments_Results.csv : contains resulting info related to time
%    elapsed in performing each combinations, solving each time the whole
%    problem 
%    - if starting problem is 1) then the file will contain
%    (id, mean_ThinQR_time_elapsed, std_ThinQR_time_elapsed, mean_QR_time_elapsed, 
%     std_QR_time_elapsed, mean_mQR_time_elapsed,std_mQR_time_elapsed ) 
%    - if starting problem is 2) then the file will contain
%    (id, mean_solver_time_elapsed, std_solver_time_elapsed, mean_svd_time_elapsed, std_svd_time_elapsed)
%
%% Parameters 
%  
% The function ExecuteExperiment_A has a unique parameter "values" which
% define the parameter values for ALSQR algorithm.
%  - values : map.container previuosly defined in Experiment_Time.m
%
%% Output 
%
% No explicit output are avaible. The result of the experiments will be saved
% in the corresponding csv file:
%   - {...}_experiments_Properties.csv and {...}_experiments_Result.csv
%   - {...}_experiments_Properties.csv and {...}_experiments_Result.csv     
%
%% Examples
%
% ExecuteExperiment_Time(values)
%
%% ------------------------------------------------------------------------

function [] = ExecuteExperiment_Time(values)

% declaring experimental type (es. "ALSQR_time")
type = values('type');

% get all possible values combinations
combs = GetCombinations(values);

% repeat each combination 5 times
time_repetita = 5; 

% total number of considered combinations
[~, tot_combinations] = size(combs);

wb = waitbar(0,'Start executing '+type+' esperiment');

for j = 1:tot_combinations

    msg = sprintf('In progress: executing combination %3.0f / %g', j, tot_combinations);
    wb = waitbar(j/tot_combinations, wb, msg);
    
    if type == "QRfactorization_time"
        
        m = combs{j}(1);
        n = combs{j}(2);

        ThinQR_time_elapsed = zeros(time_repetita,1);
        QR_time_elapsed  = zeros(time_repetita,1);
        mQR_time_elapsed = zeros(time_repetita,1);

        for i = 1:time_repetita
             
            A = randn(m,n); % Define A matrix
            
            tic % measure time elapsed for our Thin QR factorization
            [~, ~] = ThinQRfactorization(A);
            ThinQR_time_elapsed(i) = toc;
            
    
            tic % measure time elapsed for our QR factorization
            [~, ~] = QRfactorization(A);
            QR_time_elapsed(i) = toc;
            
            tic % measure time elapsed for MatLab QR factorization
            [~] = qr(A, 0);
            mQR_time_elapsed(i) = toc;
    
        end
        dlmwrite('temp.csv',[j, m,n, mean(ThinQR_time_elapsed), std(ThinQR_time_elapsed), mean(QR_time_elapsed), std(QR_time_elapsed), mean(mQR_time_elapsed), std(mQR_time_elapsed)],'delimiter',',','-append');
        textHeaderProperties = '"id","m_size", "n_size"';
        textHeaderResults = '"id", "mean_ThinQR_time_elapsed","std_ThinQR_time_elapsed", "mean_QR_time_elapsed", "std_QR_time_elapsed", "mean_mQR_time_elapsed", "std_mQR_time_elapsed"';
    else
        m = combs{j}(1);
        n = combs{j}(2);
        k = combs{j}(3);
        d = combs{j}(4);
        reg_parameter  = [combs{j}(8),combs{j}(9)];
        stop_parameter = [combs{j}(5),combs{j}(6), combs{j}(7)];

        solver_time_elapsed = zeros(time_repetita,1);
        svd_time_elapsed  = zeros(time_repetita,1);
        
        for i = 1:time_repetita
            
            % define matrix A
            A = Initialize_A(m,n);
    
            tic 
            % solve the problem with our algorithm
            [~, ~, ~, ~, ~] = Solver(A, k, reg_parameter, stop_parameter, Initialize_V(n,k), 0);
            %appA = U*V';        
            solver_time_elapsed(i) = toc;

            tic
            % solve with SVD
            [U, S, V] = svd(A);
            U = U(:, 1:k);
            S = S(1:k,1:k);
            V = V(:, 1:k);
            % compute time required          
            svd_time_elapsed(i) = toc; 

        end
        
        dlmwrite('temp.csv',[j, m,n,k,d, reg_parameter(1), reg_parameter(2), mean(solver_time_elapsed), std(solver_time_elapsed), mean(svd_time_elapsed), std(svd_time_elapsed)],'delimiter',',','-append');
        textHeaderProperties = '"id","m_size", "n_size", "k_rank", "density", "lambda_u", "lambda_v"';
        textHeaderResults = '"id", "mean_solver_time_elapsed","std_solver_time_elapsed", "mean_svd_time_elapsed", "std_svd_time_elapsed"';

    end

end
close(wb)

% read data from temp.csv and delete its content
data = csvread('temp.csv');
fclose(fopen('temp.csv','w'));

% storing matrix properties
fid = fopen(type+'_experiments_Properties.csv','w'); 
fprintf(fid,'%s\n',textHeaderProperties);
fclose(fid);
dlmwrite(type+'_experiments_Properties.csv', data(:,1:7), '-append');

% storing results
fid = fopen(type+'_experiments_Results.csv','w'); 
fprintf(fid,'%s\n',textHeaderResults);
fclose(fid);
dlmwrite(type+'_experiments_Results.csv', data(:,[1 8:end]), '-append');

