function Imputed = ImputerKeep( NaNed)
% Imputed is a matrix where the NaNs in NaNed is filled in
% in ImputerKeep only NaNs are replaced
% Calculates a singular value decomposition
% On the scaled in-data
% A= U* S* V'
% https://en.wikipedia.org/wiki/Singular-value_decomposition
% Values NaN is considered to have zero influence of decomposition
% Sven Ahlinder 2018-09-14; 2020-03-16

A= NaNed;
M= ones( size( A));
if any( any(isnan( A)))
    M( isnan( A))=0; % one if value, 0 if Nan
    A( isnan( A))=0;% NaN replaced by 0
end
[ m, n]= size( A);
%mA= mean( A);
%sA= std( A);
%A=( A- ones( m,1)* mA)./( ones( m,1)* sA);
% Creates two full rank orthogonal matrices
Uinit= ones( m, 1);
Uinit= [ Uinit, null( Uinit')];
Vinit= ones( n, 1);
Vinit= [ Vinit, null( Vinit')];

% Initiates answer matrices
U=[];
V=[];
S= [];

% No out data from optimizer
options = optimoptions(@fminunc,'Algorithm','quasi-newton','Display','off');

% optimizing one singlular value a iime
for k= 1: min( m, n)
    % Starting coefficients: 
    % Multipilcators of Uinint summing to 1, 
    % Multipilcators of Vinint summing to 1,  
    % Starting value of singular value to 1
    Cinit= [ ones( 1, m- k+ 1)/ (m- k+ 1), ones( 1, n- k+ 1)/ (n- k+ 1), 1];
    % optimizing k:th singular value
    coeff= fminunc( @( coeff) myfun( coeff, U, V, S, Uinit, Vinit, A,  k , m, n, M) , Cinit, options);
    % Updating answer matrices
    U= [U, Uinit* coeff( 1: m- k+ 1)'];
    Uinit= null (U');
    V= [V, Vinit* coeff( m- k+ 2: m- k+ 2+ n- k)'];
    Vinit= null (V');
    S= [ S, coeff( end)];
end
% make all singular values to positive
sS= sign( S);
U= ones( m, 1)* sS.* U;
V= ones( n, 1)* sS.* V;
S= sS.* S;
% Create matrix S from vector
S= diag( S);

Ainput= U* S* V';
%AinpUnsc= Ainput.*( ones( m, 1)* sA)+ ones( m,1)* mA;
AinpUnsc= Ainput;
Imputed= NaNed;
Imputed( isnan( NaNed))= AinpUnsc( isnan( NaNed));

function err= myfun( coeff, U, V,S, Uinit, Vinit, A,  k , m, n, M)
% Adding orthogonal columns to U and V
U= [U, Uinit* coeff( 1: m- k+ 1)'];
V= [V, Vinit* coeff( m- k+ 2: m- k+ 2+ n- k)'];
% See to that U and V are orthongonal
errU= sum( sum( ( U'* U- eye( k)).^2));
errV= sum( sum( ( V'* V- eye( k)).^2));
% Adding singular value to S
S= [ S, coeff( end)];
% Reshape vector to matrix
S= diag( S);
% See to that A= U*S*V'
% Difference is multipied by M element vise
% The error of NaN values will be zero
errS= sum ( sum( ((A- U* S* V').* M).^2));
% Error of fit and orthogonality
err= errS+ errV+ errU;
