$path = "lib\main.dart"
(Get-Content $path) -replace 'Text\(_prompt\s*,\s*style:\s*TextStyle\([^)]*\)\)',
'TextButton(onPressed: () { Navigator.push(context, MaterialPageRoute(builder: (_) => const CategoryScreen())); }, child: Text(_prompt, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)))' |
Set-Content -Encoding utf8 $path
