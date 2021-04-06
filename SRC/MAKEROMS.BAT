@echo off

echo>>bb.lrn ff800000
echo.>>bb.lrn
echo>>bb.lrn 2
echo.>>bb.lrn
echo>>bb.lrn img\bbvda.irw
echo>>bb.lrn bb.out
echo.>>bb.lrn
echo.>>bb.lrn
echo.>>bb.lrn
echo.>>bb.lrn
echo>>bb.lrn a

srec < bb.lrn
copy /b bbf8.0+bbfa.0+bbfc.0+bbfe.0 7m.0 /v
copy /b bbf8.1+bbfa.1+bbfc.1+bbfe.1 7m.1 /v
dataio 7m.0
dataio 7m.1

del >nul bb.lrn
