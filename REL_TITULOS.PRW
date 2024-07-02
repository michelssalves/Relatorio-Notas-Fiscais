/**********************************************************************************************************************************/
/** user function RCAP2                                                                                                           **/
/** Relatorio de contas a pagar impostos da nota de entrada.                						                                                         **/
/** Analista: Alessandro Cardozo Bueno        						                                                             **/ 
/** Data desenvolvimento: 15/12/2015 
/**Analista: Michel Alves  
/** Data de atualização: 28/06/2024    						                                                                 **/
/**********************************************************************************************************************************/
/** Parâmetro  | Tipo | Tamanho | Descrição                                                                                      **/
/**********************************************************************************************************************************/
/** Nenhum parametro esperado neste procedimento                                                                                 **/
/**********************************************************************************************************************************/
#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"

User Function RCAP2

Private oReport  := nil
Private oSection := nil
Private cPerg    := "RCAP"

criaSX1(cPerg)

Pergunte(cPerg, .F.)
                                                                                                           
oReport := GerRelDef(cPerg)

oReport:PrintDialog()

Return 

/**********************************************************************************************************************************/
/** static function GerRelDef()                                                                                                  **/
/** definição dos objetos do relatório                                                                                           **/
/**********************************************************************************************************************************/
Static Function GerRelDef(cPerg)

// define o relatório
oReport := TReport():New("RCAP", "Relatório Contas a Pagar", cPerg, {|oReport| GerRelExe()}, "Este relatório imprime dados sobre o titulos a pagar com relacionando fornecedores e NF de entrada.")
oReport:cFontBody := 'Courier New'
oReport:nFontBody := 8

// define a seção principal
oSection := TRSection():New(oReport, "Titulos", {},,,,,,.T.,,,,,,,,,,,,)  

TRCell():New(oSection,"FILIAL"         , nil, "Filial "          ,"@!", 3)
TRCell():New(oSection,"NOTAFISCAL"     , nil, "Nota Fiscal "     ,"@!", 6)
TRCell():New(oSection,"FORNECEDOR"     , nil, "Fornecedor"       ,"@!", 6) 
TRCell():New(oSection,"LOJA"           , nil, "Loja"             ,"@!", 3)
TRCell():New(oSection,"RSOCIAL"        , nil, "R. Social"        ,"@!",10) 
TRCell():New(oSection,"CNPJ/CPF"       , nil, "CNPJ/CPF"         ,"@R 99.999.999/9999-99",15) 
TRCell():New(oSection,"EMISSAO"        , nil, "Emissão"          ,"@!", 8)
TRCell():New(oSection,"ESTADO"         , nil, "Estado"           ,"@!", 2)
TRCell():New(oSection,"VLRTIT"         , nil, "Vlr. Liquido"       ,"@E 999,999,999,999.99", 17)
TRCell():New(oSection,"DIGITACAO"      , nil, "Dt. Digitação"    ,"@!", 8)  
TRCell():New(oSection,"ESPDOC"         , nil, "Tp. Doc."         ,"@!", 5)  
TRCell():New(oSection,"VLRINSS"        , nil, "Vlr. INSS"        ,"@E 999,999,999,999.99", 17)  
TRCell():New(oSection,"VLRISS"         , nil, "Vlr. ISS"         ,"@E 999,999,999,999.99", 17)  
TRCell():New(oSection,"VLRPIS"         , nil, "Vlr PIS"          ,"@E 999,999,999,999.99", 17)  
TRCell():New(oSection,"VLRCOF"         , nil, "Vlr. Cofins"      ,"@E 999,999,999,999.99", 17)  
TRCell():New(oSection,"VLRCSLL"        , nil, "Vlr. CSLL"        ,"@E 999,999,999,999.99", 17)
TRCell():New(oSection,"IRRET"          , nil, "IR Retido"        ,"@E 999,999,999,999.99", 17)
TRCell():New(oSection,"VCTOREAL"       , nil, "Vcto. Real"       ,"@!", 8) 
TRCell():New(oSection,"VLRBRUTO"       , nil, "Vlr. Bruto"       ,"@E 999,999,999,999.99", 17)
TRCell():New(oSection,"TOTAL_PEDIDO"   , nil, "Vlr. Pedido"      ,"@E 999,999,999,999.99", 17)
TRCell():New(oSection,"TOTAL_NOTAS"    , nil, "Vlr. Notas"       ,"@E 999,999,999,999.99", 17)
TRCell():New(oSection,"DIFERENCA"      , nil, "Saldo"   		 ,"@E 999,999,999,999.99", 17)
TRCell():New(oSection,"MOEDA"     	   , nil, "Moeda"   		 ,"@E 999,999,999,999.99", 17)
TRCell():New(oSection,"NUM_PEDIDO"     , nil, "Pedido Compras"   ,"@!", 6)
TRCell():New(oSection,"COND_DESCRI"    , nil, "Cond.Pag"         ,"@!", 50)
TRCell():New(oSection,"C7_USER"    	   , nil, "Nome Comprador"   ,"@!", 30)

Return(oReport)    

/**********************************************************************************************************************************/
/** static function GerRelExe()                                                                                                  **/
/** processamento do relatório                                                                                                   **/
/**********************************************************************************************************************************/
Static Function GerRelExe()

Local cAliaSC71 := getNextAlias()
Local cAliaSC72 := getNextAlias()
Local cAliaSC73 := getNextAlias()
Local cQuery1:=""
Local cQuery2:=""
Local cQuery3:=""

cDtAtual := DTOS(Date())

oSection:Init() 
SF1QRY()
SF1QRY->(DbGoTop())
While (!SF1QRY->(Eof()))

		cQuery1 := " SELECT SC7.C7_NUM" + CRLF
		cQuery1 += " FROM " + RetSqlName("SC7") + " SC7 (NOLOCK) INNER JOIN " + RetSqlName("SD1") + " SD1 (NOLOCK) ON SD1.D1_PEDIDO = SC7.C7_NUM AND SD1.D1_ITEMPC = SC7.C7_ITEM" + CRLF
	    cQuery1 += " AND SD1.D_E_L_E_T_ = '' AND SC7.D_E_L_E_T_ = '' AND SC7.C7_RESIDUO <> 'S' " + CRLF  
	    cQuery1 += " AND SD1.D1_FILIAL = '" + xFilial("SD1") + "' " + CRLF  
		cQuery1 += " AND SD1.D1_DOC = '"+SF1QRY->NOTA+"' " + CRLF  
		cQuery1 += " AND SD1.D1_FORNECE = '"+SF1QRY->FORNECEDOR+"' " + CRLF  
		cQuery1 += " AND SD1.D1_LOJA = '"+SF1QRY->LOJA+"' "  + CRLF 
	    cQuery1 := ChangeQuery(cQuery1)     
	    
		If Select(cAliaSC71) > 0
			(cAliaSC71)->(DbCloseArea())
		Endif
		
		TCQUERY cQuery1 NEW ALIAS (cAliaSC71)

		cQuery3 := "SELECT ISNULL(SUM(D1_TOTAL),'0') ACUMULADO FROM SD1020 SD1 (NOLOCK) WHERE D1_PEDIDO = '"+(cAliaSC71)->C7_NUM+"' " + CRLF
			If ( !Empty(MV_PAR08))
				cQuery3 += " AND SD1.D1_EMISSAO <= '"+DtoS(MV_PAR08)+"' " + CRLF 
			Else
				cQuery3 += " AND SD1.D1_EMISSAO <= '"+cDtAtual+"' " + CRLF
			EndIf
		cQuery3 += " AND SD1.D_E_L_E_T_ = '' " + CRLF  
	    cQuery3 := ChangeQuery(cQuery3)     
	    
		If Select(cAliaSC73) > 0
			(cAliaSC73)->(DbCloseArea())
		Endif

		TCQUERY cQuery3 NEW ALIAS (cAliaSC73)

		cQuery2 := "SELECT "
		cQuery2 += " ISNULL(SUM(SC7.C7_TOTAL) + SUM(SC7.C7_FRETE), '0') AS C7_TOTAL, " + CRLF
		cQuery2 += " SUM(C7_QUJE) AS ENTREGUE, SUM(C7_QUANT) AS SOLICITADO, (SUM(SC7.C7_QUANT) - SUM(SC7.C7_QUJE)) AS DIFERENCA " + CRLF
		cQuery2 += " FROM " + RetSqlName("SC7") + " SC7 (NOLOCK) " + CRLF
		cQuery2 += " WHERE SC7.D_E_L_E_T_ = '' " + CRLF
		cQuery2 += " AND SC7.C7_FILIAL = '" + xFilial("SC7") + "' " + CRLF
		cQuery2 += " AND SC7.C7_FORNECE = '" + SF1QRY->FORNECEDOR + "' " + CRLF
		cQuery2 += " AND SC7.C7_NUM = '" + (cAliaSC71)->C7_NUM + "' " + CRLF

	    cQuery2 := ChangeQuery(cQuery2)     
	    
		If Select(cAliaSC72) > 0
			(cAliaSC72)->(DbCloseArea())
		Endif

		TCQUERY cQuery2 NEW ALIAS (cAliaSC72)

 		oSection:Cell("FILIAL")           :SetValue(SF1QRY->FILIAL)     
     	oSection:Cell("NOTAFISCAL")       :SetValue(SF1QRY->NOTA)  
     	oSection:Cell("FORNECEDOR")       :SetValue(SF1QRY->FORNECEDOR) 
   		oSection:Cell("LOJA")             :SetValue(SF1QRY->LOJA) 
    	oSection:Cell("RSOCIAL")          :SetValue(SF1QRY->RAZAO) 
    	oSection:Cell("CNPJ/CPF")         :SetValue(SF1QRY->CGC) 
    	oSection:Cell("EMISSAO")          :SetValue(SUBSTR(SF1QRY->EMISSAO,7,2)+'/'+SUBSTR(SF1QRY->EMISSAO,5,2)+'/'+SUBSTR(SF1QRY->EMISSAO,1,4))
     	oSection:Cell("ESTADO")           :SetValue(SF1QRY->ESTADO) 
    	oSection:Cell("VLRTIT")           :SetValue(SF1QRY->VLRLIQ) 
    	oSection:Cell("DIGITACAO")        :SetValue(SUBSTR(SF1QRY->DIGITACAO,7,2)+'/'+SUBSTR(SF1QRY->DIGITACAO,5,2)+'/'+SUBSTR(SF1QRY->DIGITACAO,1,4))
    	oSection:Cell("ESPDOC")           :SetValue(SF1QRY->TIPO) 
    	oSection:Cell("VLRINSS")          :SetValue(SF1QRY->VLRINSS) 
	    oSection:Cell("VLRISS")           :SetValue(SF1QRY->VLRISS) 
    	oSection:Cell("VLRPIS")           :SetValue(SF1QRY->VLRPIS) 
    	oSection:Cell("VLRCOF")           :SetValue(SF1QRY->VLRCOFINS) 
     	oSection:Cell("VLRCSLL")          :SetValue(SF1QRY->VLRCSLL) 
    	oSection:Cell("IRRET")            :SetValue(SF1QRY->VLRIR) 
    	oSection:Cell("VCTOREAL")         :SetValue(SUBSTR(SF1QRY->VENCREAL,7,2)+'/'+SUBSTR(SF1QRY->VENCREAL,5,2)+'/'+SUBSTR(SF1QRY->VENCREAL,1,4))
		If (SF1QRY->MOEDA = 0)
    		oSection:Cell("VLRBRUTO")      :SetValue(SF1QRY->VALOR) 
			oSection:Cell("TOTAL_PEDIDO") :SetValue((cAliaSC72)->C7_TOTAL) 
			oSection:Cell("TOTAL_NOTAS")  :SetValue((cAliaSC73)->ACUMULADO) 
			oSection:Cell("DIFERENCA")    :SetValue((cAliaSC72)->C7_TOTAL - SF1QRY->VALOR) 
		Else
			oSection:Cell("VLRBRUTO")      :SetValue(SF1QRY->VALOR * SF1QRY->MOEDA)
			oSection:Cell("TOTAL_PEDIDO") :SetValue((cAliaSC72)->C7_TOTAL * SF1QRY->MOEDA)
			oSection:Cell("TOTAL_NOTAS")  :SetValue((cAliaSC73)->ACUMULADO)
			oSection:Cell("DIFERENCA")    :SetValue(((cAliaSC72)->C7_TOTAL * SF1QRY->MOEDA) - (SF1QRY->VALOR * SF1QRY->MOEDA))
		EndIf
		oSection:Cell("MOEDA")     :SetValue(SF1QRY->MOEDA)
		oSection:Cell("NUM_PEDIDO")        :SetValue(Posicione('SC7',1,xFilial('SC7')+(cAliaSC71)->C7_NUM,"C7_NUM")) 
		oSection:Cell("COND_DESCRI")       :SetValue(Posicione('SE4',1,xFilial('SE4')+Posicione('SC7',1,xFilial('SC7')+(cAliaSC71)->C7_NUM,"C7_COND"),"E4_COND")) 
		oSection:Cell("C7_USER")           :SetValue(UsrFullName(Alltrim(Posicione('SC7',1,xFilial('SC7')+(cAliaSC71)->C7_NUM,"C7_USER")))) 
		
	
	oSection:PrintLine()
	
	SF1QRY->(dbSkip())    
	
EndDo                 
SF1QRY->(dbCloseArea())     
    
oSection:Finish()
Return

/**********************************************************************************************************************************/
/** static function SR8QRY                                                                                                       **/
/** restaura as informações de afastamento                                                                                       **/
/**********************************************************************************************************************************/
/** Parâmetro  | Tipo | Tamanho | Descrição                                                                                      **/
/**********************************************************************************************************************************/
/** Nenhum parametro esperado neste procedimento                                                                                 **/
/**********************************************************************************************************************************/ 
Static Function SF1QRY

  	Local aArea := GetArea()
	Local cQry  := "" 

     cQry  := "SELECT E2.E2_TXMOEDA MOEDA,F1.F1_FILIAL FILIAL,F1.F1_DOC NOTA, F1.F1_FORNECE FORNECEDOR," + CRLF
     cQry  += "       F1.F1_LOJA LOJA, A2.A2_NOME RAZAO, A2.A2_CGC CGC," + CRLF
	 cQry  += "       F1.F1_EMISSAO EMISSAO, A2.A2_EST ESTADO,  F1.F1_DTDIGIT DIGITACAO,E2.E2_VALOR VLRLIQ," + CRLF
     cQry  += "       F1.F1_ESPECIE TIPO, " + CRLF
	 cQry  += "       E2.E2_INSS VLRINSS, E2.E2_ISS VLRISS," + CRLF
     cQry  += "       E2.E2_COFINS VLRCOFINS, E2.E2_CSLL VLRCSLL, E2.E2_IRRF VLRIR, E2.E2_PIS VLRPIS," + CRLF
     cQry  += "       E2.E2_VENCREA VENCREAL, (E2.E2_VALOR+E2.E2_INSS+E2.E2_ISS+E2.E2_COFINS+E2.E2_CSLL+E2.E2_IRRF+E2.E2_PIS) VALOR" + CRLF
     cQry  += " FROM "+ RetSqlName("SF1") +" F1 (NOLOCK), "+ RetSqlName("SE2") +" E2 (NOLOCK), "+ RetSqlName("SA2") +" A2 (NOLOCK)" + CRLF
     //cQry  += " WHERE F1.F1_DOC BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"'" + CRLF
     cQry  += "  AND F1.F1_FILIAL  BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"'"
	 cQry  += "  and F1.F1_DTDIGIT between 20240124 and 20240124 "  + CRLF
     cQry  += "  AND F1.F1_DTDIGIT BETWEEN '"+DtoS(MV_PAR07)+"' AND '"+DtoS(MV_PAR08)+"'" + CRLF  
     cQry  += "  AND F1.F1_FORNECE BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"'" + CRLF
     cQry  += "  AND F1.D_E_L_E_T_ = ''" + CRLF
     cQry  += "  AND E2.E2_FILIAL = F1.F1_FILIAL" + CRLF
     cQry  += "  AND E2.E2_FORNECE = F1.F1_FORNECE" + CRLF
     cQry  += "  AND E2.E2_LOJA = F1.F1_LOJA" + CRLF
     cQry  += "  AND E2.E2_NUM = F1.F1_DOC" + CRLF
     cQry  += "  AND E2.E2_EMISSAO = F1.F1_EMISSAO" + CRLF
     cQry  += "  AND E2.D_E_L_E_T_ = ''" + CRLF
     cQry  += "  AND A2.A2_COD = F1.F1_FORNECE" + CRLF
     cQry  += "  AND A2.A2_LOJA = F1.F1_LOJA" + CRLF
     cQry  += "  AND A2.D_E_L_E_T_ = ''" + CRLF
          
     If(mv_par09 == 1)
    	 cQry  += "   AND E2.E2_SALDO = 0" + CRLF
     EndIf

     If(mv_par09 == 2)
     	 cQry  += "   AND E2.E2_SALDO <> 0" + CRLF
     EndIf
     
     cQry  += " GROUP BY  F1.F1_FILIAL,F1.F1_DOC, F1.F1_FORNECE," + CRLF
     cQry  += " F1.F1_LOJA, A2.A2_NOME, A2.A2_CGC, F1.F1_EMISSAO," + CRLF
     cQry  += " A2.A2_EST, E2.E2_VALOR, F1.F1_DTDIGIT," + CRLF
     cQry  += " F1.F1_ESPECIE, E2.E2_INSS, E2.E2_ISS," + CRLF
     cQry  += " E2.E2_COFINS, E2.E2_CSLL, E2.E2_IRRF, E2.E2_PIS," + CRLF
     cQry  += " E2.E2_VENCREA, (E2.E2_VALOR+E2.E2_INSS+E2.E2_VRETISS+E2.E2_COFINS+E2.E2_CSLL+E2.E2_IRRF+E2.E2_PIS), E2.E2_TXMOEDA" + CRLF
     
    TcQuery cQry New Alias "SF1QRY"
	// restaura area
	RestArea(aArea)  

Return
/**********************************************************************************************************************************/
/** static function criaSX1                                                                                                      **/
/** cria perguntas.											                                                                     **/
/**********************************************************************************************************************************/
/** Parâmetro  | Tipo | Tamanho | Descrição                                                                                      **/
/**********************************************************************************************************************************/
/** Nenhum parametro esperado neste procedimento                                                                                 **/
/**********************************************************************************************************************************/
Static function criaSX1(cPerg)

	PutSx1(cPerg,"01","Filial de?"             ,"Filial de?"       ,"Filial de?"          ,"mv_ch1"  ,"C" ,2,0,0,"G","",""   ,"","","mv_par01","","","","","","","","","","","","","","","","",{"Filial inicio."   ,"","",""},{"","","",""},{"","",""},"")
	PutSx1(cPerg,"02","Filial até?"            ,"Filial até?"      ,"Filial até?"         ,"mv_ch2"  ,"C" ,2,0,0,"G","",""   ,"","","mv_par02","","","","","","","","","","","","","","","","",{"Filial fim."      ,"","",""},{"","","",""},{"","",""},"")
	PutSx1(cPerg,"03","NF de?"                 ,"NF de?"           ,"NF de?"              ,"mv_ch3"  ,"C" ,9,0,0,"G","",""   ,"","","mv_par03","","","","","","","","","","","","","","","","",{"NF de."           ,"","",""},{"","","",""},{"","",""},"")
	PutSx1(cPerg,"04","NF até?"                ,"NF até?"          ,"NF até?"             ,"mv_ch4"  ,"C" ,9,0,0,"G","",""   ,"","","mv_par04","","","","","","","","","","","","","","","","",{"NF até."          ,"","",""},{"","","",""},{"","",""},"")
	PutSx1(cPerg,"05","Pedido de?"             ,"Pedido de?"       ,"Pedido de?"          ,"mv_ch5"  ,"C" ,6,0,0,"G","",""   ,"","","mv_par05","","","","","","","","","","","","","","","","",{"Pedido de."       ,"","",""},{"","","",""},{"","",""},"")
	PutSx1(cPerg,"06","Pedido até?"            ,"Pedido até?"      ,"Pedido até?"         ,"mv_ch6"  ,"C" ,6,0,0,"G","",""   ,"","","mv_par06","","","","","","","","","","","","","","","","",{"Pedido até."      ,"","",""},{"","","",""},{"","",""},"")
	PutSx1(cPerg,"05","Fornecedor de?"         ,"Fornecedor de?"   ,"Fornecedor de?"      ,"mv_ch5"  ,"C" ,6,0,0,"G","","SA2","","","mv_par05","","","","","","","","","","","","","","","","",{"Fornecedor de."   ,"","",""},{"","","",""},{"","",""},"")
	PutSx1(cPerg,"06","Fornecedor até?"        ,"Fornecedor até?"  ,"Fornecedor até?"     ,"mv_ch6"  ,"C" ,6,0,0,"G","","SA2","","","mv_par06","","","","","","","","","","","","","","","","",{"Fornecedor até."  ,"","",""},{"","","",""},{"","",""},"")
	PutSx1(cPerg,"07","Digitação de?"          ,"Digitação de?"    ,"Digitação de?"       ,"mv_ch7"  ,"D" ,8,0,0,"G","",""   ,"","","mv_par07","","","","","","","","","","","","","","","","",{"Digitação de."    ,"","",""},{"","","",""},{"","",""},"")
	PutSx1(cPerg,"08","Digitação até?"         ,"Digitação até?"   ,"Digitação até?"      ,"mv_ch8"  ,"D" ,8,0,0,"G","",""   ,"","","mv_par08","","","","","","","","","","","","","","","","",{"Digitação até."   ,"","",""},{"","","",""},{"","",""},"")
	PutSx1(cPerg,"09","Liquidado?"             ,"Liquidado?"       ,"Liquidado?"          ,"mv_ch9"  ,"C" ,1,0,0,"C","",""   ,"","","mv_par09","Sim","Sim","Sim","Não","Não","Não","Ambos","Ambos","Ambos","","","","","","","",{"Liquidado?.","","",""},{"","","",""},{"","",""},"")

Return
