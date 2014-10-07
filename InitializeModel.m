% Want to distribute this code? Have other questions? -> sbowman@stanford.edu
function [ theta, thetaDecoder, constWordFeatures ] = InitializeModel(wordMap, hyperParams)
% Initialize the learned parameters of the model. 

vocabLength = size(wordMap, 1);
DIM = hyperParams.dim;
PENULT = hyperParams.penultDim;
TOPD = hyperParams.topDepth;
NUMTRANS = hyperParams.embeddingTransformDepth;
if ~hyperParams.untied
    NUMCOMP = 1;
else
    NUMCOMP = 3;
end

% Randomly initialize softmax layer
classifierParameters = rand(sum(hyperParams.numRelations), PENULT + 1) .* .02 - .01;

% Randomly initialize tensor parameters
if hyperParams.useThirdOrderComparison
    classifierMatrices = rand(DIM , DIM, PENULT) .* .02 - .01;
else
    classifierMatrices = zeros(0, 0, PENULT) .* .02 - .01;
end
classifierMatrix = rand(PENULT, DIM * 2) .* .02 - .01;
classifierBias = rand(PENULT, 1) .* .02 - .01;
if hyperParams.useThirdOrder
    compositionMatrices = rand(DIM, DIM, DIM, NUMCOMP) .* .02 - .01;
else
    compositionMatrices = zeros(0, 0, 0, NUMCOMP) .* .02 - .01;
end
compositionMatrix = rand(DIM, DIM * 2, NUMCOMP) .* .02 - .01; 
compositionBias = rand(DIM, NUMCOMP) .* .02 - .01;

classifierExtraMatrix = rand(PENULT, PENULT, TOPD - 1) .* .02 - .01;
classifierExtraBias = rand(PENULT, TOPD - 1) .* .02 - .01;

embeddingTransformMatrix = rand(DIM, DIM, NUMTRANS) .* .02 - .01;
embeddingTransformBias = rand(DIM, NUMTRANS) .* .02 - .01;
for matrixDepth = 1:NUMTRANS
    embeddingTransformMatrix(:, :, matrixDepth) = ...
        embeddingTransformMatrix(:, :, matrixDepth) + eye(DIM);
end

if hyperParams.loadWords
   Log(hyperParams.statlog, 'Loading the vocabulary.')
   wordFeatures = InitializeVocabFromFile(wordMap);
   if ~hyperParams.trainWords
       Log(hyperParams.statlog, 'Warning: Word vectors are randomly initialized and not trained.');     
   end
else 
    % Randomly initialize the words
    wordFeatures = rand(vocabLength, DIM) .* .02 - .01;
end

if ~hyperParams.trainWords
    % Move the initialized word features into constWordFeatures
    constWordFeatures = wordFeatures;
    wordFeatures = [];
else
    constWordFeatures = [];
end

[theta, thetaDecoder] = param2stack(classifierMatrices, classifierMatrix, ...
    classifierBias, classifierParameters, wordFeatures, compositionMatrices, ...
    compositionMatrix, compositionBias, classifierExtraMatrix, ...
    classifierExtraBias, embeddingTransformMatrix, embeddingTransformBias);

end

