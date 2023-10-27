function [Res] = GetRes(CurrSt,PrevSt)
    mdl = fitlm(CurrSt,PrevSt);
    ResTab = mdl.Residuals;
    Res = ResTab.Raw;
end
