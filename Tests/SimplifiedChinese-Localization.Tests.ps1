# Read-only localization tests: never load the debloat entry point or feature scripts.
BeforeAll {
    . (Join-Path $PSScriptRoot '..\Scripts\FileIO\Import-JsonFile.ps1')
    . (Join-Path $PSScriptRoot '..\Scripts\FileIO\Import-LanguageFile.ps1')
    $script:ZhLanguagesPath = Join-Path $PSScriptRoot '..\Config\Languages'
    $script:ZhLang = Import-LanguageFile -LanguageCode 'zh-CN' -LanguagesPath $script:ZhLanguagesPath

    function Get-ZhTestLeaves {
        param($Value, [string]$Prefix = '')
        if ($Value -is [string]) {
            [PSCustomObject]@{ Path = $Prefix; Text = $Value }
            return
        }
        foreach ($property in $Value.PSObject.Properties) {
            Get-ZhTestLeaves -Value $property.Value -Prefix "$Prefix/$($property.Name)"
        }
    }
}

Describe 'Simplified Chinese language catalogs' {
    It 'discovers and loads zh-CN with English fallback' {
        @(Get-AvailableLanguageFolders -LanguagesPath $script:ZhLanguagesPath | Select-Object -ExpandProperty Name) | Should -Contain 'zh-CN'
        $script:ZhLang.LanguageCode | Should -Be 'zh-CN'
        $script:ZhLang.Fallback.LanguageCode | Should -Be 'en-US'
    }

    It 'has exactly the English translation key set' {
        $coverage = Test-LanguageKeyCoverage -LanguageCode 'zh-CN' -LanguagesPath $script:ZhLanguagesPath
        $coverage.ResolvedLanguageCode | Should -Be 'zh-CN'
        @($coverage.MissingKeys).Count | Should -Be 0
        @($coverage.ExtraKeys).Count | Should -Be 0
    }

    It 'preserves format placeholders and nonempty text in <Catalog>' -ForEach @(
        @{ Catalog = 'Chrome' }
        @{ Catalog = 'Features' }
        @{ Catalog = 'Categories' }
        @{ Catalog = 'Apps' }
    ) {
        $english = Get-Content -LiteralPath (Join-Path $script:ZhLanguagesPath "en-US/$Catalog.json") -Raw -Encoding UTF8 | ConvertFrom-Json
        $chinese = Get-Content -LiteralPath (Join-Path $script:ZhLanguagesPath "zh-CN/$Catalog.json") -Raw -Encoding UTF8 | ConvertFrom-Json
        $expected = @{}
        foreach ($leaf in (Get-ZhTestLeaves $english)) { $expected[$leaf.Path] = $leaf.Text }
        $actual = @(Get-ZhTestLeaves $chinese)
        $actual.Count | Should -Be $expected.Count
        foreach ($leaf in $actual) {
            $expected.ContainsKey($leaf.Path) | Should -BeTrue -Because $leaf.Path
            $leaf.Text.Trim() | Should -Not -BeNullOrEmpty -Because $leaf.Path
            $pattern = '(?<!\{)\{\d+(?:,[^{}:]+)?(?::[^{}]+)?\}(?!\})'
            $sourceTokens = @([regex]::Matches($expected[$leaf.Path], $pattern) | ForEach-Object { $_.Value } | Sort-Object) -join '|'
            $targetTokens = @([regex]::Matches($leaf.Text, $pattern) | ForEach-Object { $_.Value } | Sort-Object) -join '|'
            $targetTokens | Should -Be $sourceTokens -Because $leaf.Path
        }
    }

    It 'uses the other plural category for Chinese count <Count>' -ForEach @(
        @{ Count = 0 }
        @{ Count = 1 }
        @{ Count = 2 }
        @{ Count = 1000000 }
    ) {
        Get-PluralCategory -LanguageCode 'zh-CN' -Count $Count | Should -Be 'other'
        $text = Get-Translation -Key 'AppsSelectedCount' -Count $Count -FormatArgs @($Count) -Lang $script:ZhLang
        $text | Should -Be ($script:ZhLang.Chrome.AppsSelectedCount_other -f $Count)
    }
}
