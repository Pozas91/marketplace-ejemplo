-- Filtro de pandoc para exportar la wiki a un manual en Word.
-- - Quita las citas al código "(ruta/fichero.ext:120-134)" salvo que se pida -M citas=true
-- - Convierte los enlaces entre páginas (.md) en texto: en Word no llevan a ningún sitio
-- - Salto de página antes de cada capítulo (título de nivel 1)
-- - "[!warning]" y similares pasan a una etiqueta en negrita
-- - Los bloques Mermaid se dejan como texto con un aviso
-- - Idioma y título del índice en español si no vienen dados

local mantener_citas = false

local etiquetas = {
  warning = "Aviso:",
  note = "Nota:",
  tip = "Consejo:",
  important = "Importante:",
  caution = "Precaución:",
}

local function es_cita(texto)
  -- ruta con extensión seguida de :línea, por ejemplo src/a/B.cs:12 o B.cs:12-30
  return texto:match("[%w_%-%./\\]+%.%w+:%d+") ~= nil
end

local function quitar_citas(inlines)
  if mantener_citas then
    return inlines
  end
  local resultado = pandoc.List()
  local i = 1
  local n = #inlines
  while i <= n do
    local el = inlines[i]
    local texto = pandoc.utils.stringify(el)
    local quitado = false
    if texto:sub(1, 1) == "(" then
      -- buscar el cierre del paréntesis en los siguientes elementos
      local acumulado = ""
      for j = i, math.min(n, i + 60) do
        acumulado = acumulado .. (inlines[j].t == "Space" and " " or pandoc.utils.stringify(inlines[j]))
        local cierre = acumulado:find("%)[%.,;:]?$")
        if cierre then
          if es_cita(acumulado) then
            -- conservar la puntuación que va pegada al paréntesis
            local resto = acumulado:match("%)([%.,;:]?)$")
            -- quitar el espacio anterior
            if #resultado > 0 and resultado[#resultado].t == "Space" then
              resultado:remove(#resultado)
            end
            if resto and resto ~= "" then
              resultado:insert(pandoc.Str(resto))
            end
            i = j + 1
            quitado = true
          end
          break
        end
      end
    end
    if not quitado then
      resultado:insert(el)
      i = i + 1
    end
  end
  return resultado
end

local function es_enlace_interno(destino)
  return destino:match("%.md$") or destino:match("%.md#")
end

return {
  {
    Meta = function(meta)
      if meta.citas and pandoc.utils.stringify(meta.citas) == "true" then
        mantener_citas = true
      end
      if not meta.lang then
        meta.lang = "es-ES"
      end
      if not meta["toc-title"] then
        meta["toc-title"] = pandoc.MetaInlines({ pandoc.Str("Índice") })
      end
      return meta
    end,
  },
  {
    Inlines = quitar_citas,

    Link = function(el)
      if es_enlace_interno(el.target) then
        return el.content
      end
    end,

    -- > [!warning] Revisar
    -- > texto...
    -- pasa a: "Aviso: Revisar" en negrita y el texto en un párrafo aparte
    BlockQuote = function(el)
      local primero = el.content[1]
      if not primero or primero.t ~= "Para" then
        return nil
      end
      local inl = primero.content
      local tipo = inl[1] and inl[1].t == "Str" and inl[1].text:match("^%[!(%a+)%]$")
      if not tipo then
        return nil
      end
      local etiqueta = etiquetas[tipo:lower()] or (tipo .. ":")
      local titulo = pandoc.List({ pandoc.Str(etiqueta) })
      local cuerpo = pandoc.List()
      local en_titulo = true
      for k = 2, #inl do
        if en_titulo and (inl[k].t == "SoftBreak" or inl[k].t == "LineBreak") then
          en_titulo = false
        elseif en_titulo then
          titulo:insert(inl[k])
        else
          cuerpo:insert(inl[k])
        end
      end
      local bloques = pandoc.List({ pandoc.Para({ pandoc.Strong(titulo) }) })
      if #cuerpo > 0 then
        bloques:insert(pandoc.Para(cuerpo))
      end
      for k = 2, #el.content do
        bloques:insert(el.content[k])
      end
      el.content = bloques
      return el
    end,

    CodeBlock = function(el)
      if el.classes:includes("mermaid") then
        return {
          pandoc.Para({ pandoc.Emph({ pandoc.Str("Diagrama: ver la versión gráfica en la wiki.") }) }),
          el,
        }
      end
    end,

    -- el primero también: así el índice queda en su propia página
    Header = function(el)
      if el.level == 1 then
        return {
          pandoc.RawBlock("openxml", '<w:p><w:r><w:br w:type="page"/></w:r></w:p>'),
          el,
        }
      end
    end,
  },
}
