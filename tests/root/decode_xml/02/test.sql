SELECT 
  decode_xml('&quot;2&quot; &gt; 1 &amp; &apos;5&apos; &lt; 7') = '"2" > 1 & ''5'' < 7'
;

